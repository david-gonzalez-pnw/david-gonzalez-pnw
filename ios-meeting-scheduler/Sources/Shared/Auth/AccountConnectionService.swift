import Foundation

/// Connects/disconnects calendar accounts and persists the set of connected
/// accounts (shared with the extension via the App Group).
///
/// The real implementation runs provider OAuth from the host app via
/// `ASWebAuthenticationSession`, hands the auth code to the backend, and stores
/// only references locally — tokens live server-side with the unified provider.
public protocol AccountConnectionService {
    func connectedAccounts() -> [ConnectedAccount]
    func connect(_ kind: CalendarProviderKind) async throws -> ConnectedAccount
    func disconnect(_ accountID: String) throws
    func setDefault(_ accountID: String) throws
}

/// Fakes connection and persists to the shared App Group defaults so both
/// targets see the same accounts. Replace with a real OAuth-backed service later.
public final class StubAccountConnectionService: AccountConnectionService {
    private let defaults: UserDefaults
    private let storageKey = "convene.connectedAccounts"

    public init(defaults: UserDefaults? = ConveneConfig.sharedDefaults) {
        self.defaults = defaults ?? .standard
    }

    public func connectedAccounts() -> [ConnectedAccount] {
        guard let data = defaults.data(forKey: storageKey),
              let accounts = try? JSONCoders.decoder.decode([ConnectedAccount].self, from: data) else {
            return []
        }
        return accounts
    }

    public func connect(_ kind: CalendarProviderKind) async throws -> ConnectedAccount {
        var accounts = connectedAccounts()
        let account = ConnectedAccount(
            id: UUID().uuidString,
            kind: kind,
            email: "you@\(kind.rawValue).example",
            isDefault: accounts.isEmpty // first connected account becomes default
        )
        accounts.append(account)
        persist(accounts)
        return account
    }

    public func disconnect(_ accountID: String) throws {
        var accounts = connectedAccounts()
        let wasDefault = accounts.first(where: { $0.id == accountID })?.isDefault ?? false
        accounts.removeAll { $0.id == accountID }
        if wasDefault, !accounts.isEmpty {
            accounts[0].isDefault = true
        }
        persist(accounts)
    }

    public func setDefault(_ accountID: String) throws {
        var accounts = connectedAccounts()
        for idx in accounts.indices {
            accounts[idx].isDefault = (accounts[idx].id == accountID)
        }
        persist(accounts)
    }

    private func persist(_ accounts: [ConnectedAccount]) {
        if let data = try? JSONCoders.encoder.encode(accounts) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
