import EventKit
import Foundation

/// On-device calendar access via EventKit. Powers the no-backend path:
/// the organizer writing to a local/iCloud calendar, and any recipient adding
/// the shared event to their own default calendar with one tap.
///
/// EventKit only sees accounts already configured on the device and cannot track
/// cross-provider RSVP — that requires the remote provider (see ARCHITECTURE.md §4).
public final class EventKitCalendarService: CalendarSyncProvider {
    private let store: EKEventStore

    public init(store: EKEventStore = EKEventStore()) {
        self.store = store
    }

    public func requestAccess() async throws {
        if #available(iOS 17.0, *) {
            let granted = try await store.requestFullAccessToEvents()
            if !granted { throw CalendarSyncError.accessDenied }
        } else {
            let granted = try await store.requestAccess(to: .event)
            if !granted { throw CalendarSyncError.accessDenied }
        }
    }

    public func availableCalendars() async throws -> [CalendarRef] {
        try await requestAccess()
        return store.calendars(for: .event)
            .filter { $0.allowsContentModifications }
            .map { CalendarRef(id: $0.calendarIdentifier,
                               title: $0.title,
                               accountName: $0.source.title,
                               allowsModification: true) }
    }

    public func createEvent(_ event: MeetingEvent, in calendarID: String) async throws -> SyncedEventRef {
        try await requestAccess()

        guard let calendar = store.calendar(withIdentifier: calendarID) ?? store.defaultCalendarForNewEvents else {
            throw CalendarSyncError.calendarNotFound
        }

        let ekEvent = EKEvent(eventStore: store)
        ekEvent.calendar = calendar
        ekEvent.title = event.title
        ekEvent.startDate = event.start
        ekEvent.endDate = event.end
        ekEvent.location = event.location
        ekEvent.notes = event.notes

        do {
            try store.save(ekEvent, span: .thisEvent, commit: true)
        } catch {
            throw CalendarSyncError.provider(error.localizedDescription)
        }

        return SyncedEventRef(remoteID: ekEvent.eventIdentifier ?? event.id.uuidString,
                              calendarID: calendar.calendarIdentifier,
                              icsURL: event.icsURL)
    }

    /// EventKit does not model cross-account RSVP; the remote provider handles this.
    public func updateRSVP(remoteID: String, attendee: Attendee, status: RSVPStatus) async throws {
        throw CalendarSyncError.unsupported("RSVP tracking requires the remote provider")
    }

    /// Convenience for the recipient "add to my calendar" tap.
    public func addToDefaultCalendar(_ event: MeetingEvent) async throws -> SyncedEventRef {
        try await requestAccess()
        guard let defaultCalendar = store.defaultCalendarForNewEvents else {
            throw CalendarSyncError.calendarNotFound
        }
        return try await createEvent(event, in: defaultCalendar.calendarIdentifier)
    }
}
