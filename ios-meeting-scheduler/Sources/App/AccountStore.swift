import Foundation
import ConveneKit

/// Observable wrapper over `AccountConnectionService` for the SwiftUI host app.
@MainActor
final class AccountStore: ObservableObject {
    @Published private(set) var accounts: [ConnectedAccount] = []
    @Published var isWorking = false
    @Published var errorMessage: String?

    private let service: AccountConnectionService

    init(service: AccountConnectionService = StubAccountConnectionService()) {
        self.service = service
        reload()
    }

    var defaultAccount: ConnectedAccount? { accounts.first(where: { $0.isDefault }) }

    func reload() {
        accounts = service.connectedAccounts()
    }

    func connect(_ kind: CalendarProviderKind) async {
        isWorking = true
        defer { isWorking = false }
        do {
            _ = try await service.connect(kind)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func disconnect(_ accountID: String) {
        do {
            try service.disconnect(accountID)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setDefault(_ accountID: String) {
        do {
            try service.setDefault(accountID)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
