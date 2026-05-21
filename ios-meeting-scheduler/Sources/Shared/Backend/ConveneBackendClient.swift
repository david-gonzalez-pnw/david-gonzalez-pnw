import Foundation

/// Client for the Convene backend, which brokers Cronofy OAuth. The backend
/// holds the Cronofy client secret and refresh tokens; the app only ever
/// receives short-lived access tokens.
public protocol ConveneBackendClient {
    func exchangeCronofyCode(_ request: API.CronofyExchangeRequest) async throws -> API.CronofyExchangeResponse
    func refreshCronofyAccessToken(accountID: String) async throws -> API.CronofyRefreshResponse
}

/// Fakes the OAuth exchange so the host-app connect flow runs before the backend
/// exists. The returned token is not a real Cronofy token — `CalendarProviderFactory`
/// only uses the live Cronofy provider when `CronofyConfig` is configured, so in
/// offline mode the app falls back to `StubCalendarSyncProvider`.
///
/// Phase 2 replaces this with a `URLSession` client hitting the real backend (see APIContract.swift).
public final class StubBackendClient: ConveneBackendClient {
    public init() {}

    public func exchangeCronofyCode(_ request: API.CronofyExchangeRequest) async throws -> API.CronofyExchangeResponse {
        API.CronofyExchangeResponse(
            accessToken: "stub-access-token",
            expiresIn: 3600,
            accountID: "stub-account",
            providerName: "Cronofy"
        )
    }

    public func refreshCronofyAccessToken(accountID: String) async throws -> API.CronofyRefreshResponse {
        API.CronofyRefreshResponse(accessToken: "stub-access-token", expiresIn: 3600)
    }
}
