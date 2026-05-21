import Foundation

/// Real `CalendarSyncProvider` backed by the Cronofy REST API.
///
/// It calls Cronofy directly with a short-lived access token supplied by
/// `tokenProvider` (sourced from `CronofyTokenStore`, refreshed via the backend).
/// The client secret never touches the device.
public final class CronofyCalendarSyncProvider: CalendarSyncProvider {
    private let config: CronofyConfig
    private let session: URLSession
    private let tokenProvider: () async throws -> String

    public init(
        config: CronofyConfig = .shared,
        session: URLSession = .shared,
        tokenProvider: @escaping () async throws -> String
    ) {
        self.config = config
        self.session = session
        self.tokenProvider = tokenProvider
    }

    public func availableCalendars() async throws -> [CalendarRef] {
        let request = try await makeRequest(path: "/v1/calendars", method: "GET")
        let response: CronofyAPI.CalendarsResponse = try await send(request)
        return response.calendars
            .filter { !($0.calendarDeleted ?? false) }
            .map { cal in
                CalendarRef(
                    id: cal.calendarId,
                    title: cal.calendarName ?? "Calendar",
                    accountName: cal.profileName,
                    allowsModification: !(cal.calendarReadonly ?? false)
                )
            }
    }

    public func createEvent(_ event: MeetingEvent, in calendarID: String) async throws -> SyncedEventRef {
        let body = CronofyAPI.UpsertEventRequest(
            eventId: event.id.uuidString,
            summary: event.title,
            description: event.notes,
            start: Self.iso(event.start),
            end: Self.iso(event.end),
            location: event.location.map { .init(description: $0) },
            attendees: invitees(from: event.attendees)
        )

        var request = try await makeRequest(path: "/v1/calendars/\(calendarID)/events", method: "POST")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        try await sendNoContent(request)

        let ics = URL(string: "https://\(ConveneConfig.universalLinkHost)/ics/\(event.id.uuidString).ics")
        return SyncedEventRef(remoteID: event.id.uuidString, calendarID: calendarID, icsURL: ics)
    }

    /// Cronofy reports attendee status via event reads and push notifications,
    /// not an organizer-side RSVP write — so RSVP arrives through the backend webhook.
    public func updateRSVP(remoteID: String, attendee: Attendee, status: RSVPStatus) async throws {
        throw CalendarSyncError.unsupported("RSVP status arrives via Cronofy push notifications")
    }

    // MARK: - Helpers

    private func invitees(from attendees: [Attendee]) -> CronofyAPI.UpsertEventRequest.Attendees? {
        let invite = attendees.compactMap { att in
            att.email.map { CronofyAPI.UpsertEventRequest.Invitee(email: $0, displayName: att.name) }
        }
        return invite.isEmpty ? nil : .init(invite: invite)
    }

    private func makeRequest(path: String, method: String) async throws -> URLRequest {
        let token = try await tokenProvider()
        var components = URLComponents(url: config.apiBaseURL, resolvingAgainstBaseURL: false)!
        components.path = path
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        try validate(response, data)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func sendNoContent(_ request: URLRequest) async throws {
        let (data, response) = try await session.data(for: request)
        try validate(response, data)
    }

    private func validate(_ response: URLResponse, _ data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw CalendarSyncError.provider("No HTTP response")
        }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw CalendarSyncError.accessDenied }
            let body = String(data: data, encoding: .utf8) ?? ""
            throw CalendarSyncError.provider("HTTP \(http.statusCode): \(body)")
        }
    }

    private static let isoFormatter = ISO8601DateFormatter()
    private static func iso(_ date: Date) -> String { isoFormatter.string(from: date) }
}
