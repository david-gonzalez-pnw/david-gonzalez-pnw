import Foundation

/// Holds the current Cronofy access token (shared between app and extension via
/// the App Group) and refreshes it through the backend when it expires.
///
/// NOTE: tokens are persisted in the App Group `UserDefaults` for the scaffold.
/// Production must store them in the shared **Keychain** access group (already
/// declared in the entitlements) instead.
public final class CronofyTokenStore {
    private let defaults: UserDefaults
    private let backend: ConveneBackendClient

    private let accessKey = "convene.cronofy.accessToken"
    private let expiryKey = "convene.cronofy.expiry"
    private let accountKey = "convene.cronofy.accountId"

    public init(defaults: UserDefaults? = ConveneConfig.sharedDefaults, backend: ConveneBackendClient = StubBackendClient()) {
        self.defaults = defaults ?? .standard
        self.backend = backend
    }

    public var hasToken: Bool { defaults.string(forKey: accessKey) != nil }
    public var accountID: String? { defaults.string(forKey: accountKey) }

    public func store(accessToken: String, expiresIn: Int, accountID: String) {
        defaults.set(accessToken, forKey: accessKey)
        defaults.set(Date().addingTimeInterval(TimeInterval(expiresIn)), forKey: expiryKey)
        defaults.set(accountID, forKey: accountKey)
    }

    public func clear() {
        [accessKey, expiryKey, accountKey].forEach { defaults.removeObject(forKey: $0) }
    }

    /// Returns a non-expired access token, refreshing via the backend if needed.
    public func validAccessToken() async throws -> String {
        let token = defaults.string(forKey: accessKey)
        let expiry = defaults.object(forKey: expiryKey) as? Date

        if let token, let expiry, expiry.timeIntervalSinceNow > 60 {
            return token
        }

        guard let accountID else { throw CalendarSyncError.accessDenied }
        let refreshed = try await backend.refreshCronofyAccessToken(accountID: accountID)
        store(accessToken: refreshed.accessToken, expiresIn: refreshed.expiresIn, accountID: accountID)
        return refreshed.accessToken
    }
}
