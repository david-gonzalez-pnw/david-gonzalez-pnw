import Foundation
import ConveneKit

/// Drives the host app's Cronofy connection: runs hosted auth, stores the
/// resulting token, and tracks the connected calendars + which is the default
/// (source of truth). When Cronofy isn't configured it loads demo calendars so
/// the scaffold is usable offline.
@MainActor
final class AccountStore: ObservableObject {
    @Published private(set) var calendars: [CalendarRef] = []
    @Published private(set) var defaultCalendarID: String?
    @Published private(set) var isConnected = false
    @Published var isWorking = false
    @Published var errorMessage: String?

    private let config: CronofyConfig
    private let backend: ConveneBackendClient
    private let tokenStore: CronofyTokenStore
    private let authCoordinator = CronofyAuthCoordinator()

    init(config: CronofyConfig = .shared, backend: ConveneBackendClient = StubBackendClient()) {
        self.config = config
        self.backend = backend
        self.tokenStore = CronofyTokenStore(backend: backend)
        reload()
    }

    func reload() {
        calendars = CalendarSelectionStore.calendars()
        defaultCalendarID = CalendarSelectionStore.defaultCalendarID()
        isConnected = tokenStore.hasToken || !calendars.isEmpty
    }

    func connect() async {
        isWorking = true
        defer { isWorking = false }
        do {
            let fetched: [CalendarRef]
            if config.isConfigured {
                let code = try await authCoordinator.authenticate(config: config)
                let result = try await backend.exchangeCronofyCode(
                    API.CronofyExchangeRequest(code: code, redirectURI: config.redirectURI)
                )
                tokenStore.store(accessToken: result.accessToken, expiresIn: result.expiresIn, accountID: result.accountID)

                let tokenStore = self.tokenStore
                let provider = CronofyCalendarSyncProvider(config: config) {
                    try await tokenStore.validAccessToken()
                }
                fetched = try await provider.availableCalendars()
            } else {
                // Offline scaffold mode: no Cronofy credentials configured.
                fetched = StubCalendarSyncProvider.demoCalendars
            }

            CalendarSelectionStore.setCalendars(fetched)
            if CalendarSelectionStore.defaultCalendarID() == nil,
               let primary = fetched.first {
                CalendarSelectionStore.setDefaultCalendarID(primary.id)
            }
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setDefault(_ calendarID: String) {
        CalendarSelectionStore.setDefaultCalendarID(calendarID)
        reload()
    }

    func disconnect() {
        tokenStore.clear()
        CalendarSelectionStore.clear()
        reload()
    }
}
