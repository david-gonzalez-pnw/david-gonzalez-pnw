import Foundation

/// In-memory stand-in for the remote unified provider (Cronofy / Nylas / Composio).
/// Lets the app exercise the full create-and-sync flow before the backend exists.
/// Replace with a real `CalendarSyncProvider` implementation in Phase 2 — no app changes needed.
public actor StubCalendarSyncProvider: CalendarSyncProvider {
    private var events: [String: MeetingEvent] = [:]
    private let calendars: [CalendarRef]

    public init(calendars: [CalendarRef] = StubCalendarSyncProvider.demoCalendars) {
        self.calendars = calendars
    }

    public static let demoCalendars: [CalendarRef] = [
        CalendarRef(id: "google-primary", title: "Personal", accountName: "Google"),
        CalendarRef(id: "outlook-work", title: "Work", accountName: "Outlook"),
        CalendarRef(id: "icloud-home", title: "Home", accountName: "iCloud"),
    ]

    public func availableCalendars() async throws -> [CalendarRef] { calendars }

    public func createEvent(_ event: MeetingEvent, in calendarID: String) async throws -> SyncedEventRef {
        guard calendars.contains(where: { $0.id == calendarID }) else {
            throw CalendarSyncError.calendarNotFound
        }
        let remoteID = "stub-" + event.id.uuidString
        var stored = event
        stored.remoteID = remoteID
        events[remoteID] = stored

        let ics = URL(string: "https://\(ConveneConfig.universalLinkHost)/ics/\(remoteID).ics")
        return SyncedEventRef(remoteID: remoteID, calendarID: calendarID, icsURL: ics)
    }

    public func updateRSVP(remoteID: String, attendee: Attendee, status: RSVPStatus) async throws {
        guard var event = events[remoteID] else { throw CalendarSyncError.calendarNotFound }
        if let idx = event.attendees.firstIndex(where: { $0.id == attendee.id }) {
            event.attendees[idx].rsvp = status
        } else {
            var updated = attendee
            updated.rsvp = status
            event.attendees.append(updated)
        }
        events[remoteID] = event
    }

    public func storedEvent(remoteID: String) -> MeetingEvent? { events[remoteID] }
}
