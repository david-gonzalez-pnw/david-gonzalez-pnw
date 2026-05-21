import Foundation

/// Client for the Convene backend. The backend owns provider OAuth tokens and
/// fronts the unified calendar API; the app talks only to this.
public protocol ConveneBackendClient {
    func exchangeAuthCode(_ request: API.AuthExchangeRequest) async throws -> API.AuthExchangeResponse
    func createEvent(_ request: API.CreateEventRequest) async throws -> API.CreateEventResponse
    func submitRSVP(remoteID: String, _ request: API.RSVPRequest) async throws
}

/// Stub backed by an in-memory `StubCalendarSyncProvider`, so the app's event
/// flow works end-to-end before any server exists. Phase 2 replaces this with an
/// `URLSession`-based client hitting the real API (see APIContract.swift).
public final class StubBackendClient: ConveneBackendClient {
    private let provider: StubCalendarSyncProvider

    public init(provider: StubCalendarSyncProvider = StubCalendarSyncProvider()) {
        self.provider = provider
    }

    public func exchangeAuthCode(_ request: API.AuthExchangeRequest) async throws -> API.AuthExchangeResponse {
        let account = ConnectedAccount(
            id: UUID().uuidString,
            kind: request.provider,
            email: "you@\(request.provider.rawValue).example",
            isDefault: true
        )
        let calendars = try await provider.availableCalendars()
        return API.AuthExchangeResponse(account: account, calendars: calendars)
    }

    public func createEvent(_ request: API.CreateEventRequest) async throws -> API.CreateEventResponse {
        let ref = try await provider.createEvent(request.event, in: request.defaultCalendarID)
        for calendarID in request.mirrorCalendarIDs where calendarID != request.defaultCalendarID {
            _ = try? await provider.createEvent(request.event, in: calendarID)
        }
        return API.CreateEventResponse(ref: ref)
    }

    public func submitRSVP(remoteID: String, _ request: API.RSVPRequest) async throws {
        try await provider.updateRSVP(remoteID: remoteID, attendee: request.attendee, status: request.status)
    }
}
