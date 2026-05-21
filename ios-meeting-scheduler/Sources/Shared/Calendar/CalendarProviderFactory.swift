import Foundation

/// Chooses the concrete `CalendarSyncProvider`: real Cronofy when configured and
/// connected, otherwise the in-memory stub so the scaffold runs offline.
public enum CalendarProviderFactory {
    public static func make(
        cronofyConfig: CronofyConfig = .shared,
        tokenStore: CronofyTokenStore
    ) -> CalendarSyncProvider {
        guard cronofyConfig.isConfigured, tokenStore.hasToken else {
            return StubCalendarSyncProvider()
        }
        return CronofyCalendarSyncProvider(config: cronofyConfig) {
            try await tokenStore.validAccessToken()
        }
    }
}
