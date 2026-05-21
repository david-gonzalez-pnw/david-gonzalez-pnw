import Foundation

/// Orchestrates the "create once, sync everywhere" flow.
///
/// The event is created on the organizer's **default** calendar (the source of
/// truth that owns the attendee list and RSVP state) and mirrored to any other
/// connected calendars. The recipient side uses `EventKitCalendarService` to add
/// the event locally with one tap.
public struct CalendarSyncCoordinator {
    /// Source-of-truth + cross-provider sync (remote unified provider, stubbed today).
    public let provider: CalendarSyncProvider
    /// On-device access for the recipient "add to my calendar" tap.
    public let local: EventKitCalendarService

    public init(provider: CalendarSyncProvider, local: EventKitCalendarService = EventKitCalendarService()) {
        self.provider = provider
        self.local = local
    }

    /// Creates the event on `defaultCalendarID`, mirrors it to `mirrorCalendarIDs`,
    /// and returns the event enriched with its remote id and `.ics` link.
    @discardableResult
    public func confirmAndSync(
        _ event: MeetingEvent,
        defaultCalendarID: String,
        mirrorCalendarIDs: [String] = []
    ) async throws -> MeetingEvent {
        let primary = try await provider.createEvent(event, in: defaultCalendarID)

        for calendarID in mirrorCalendarIDs where calendarID != defaultCalendarID {
            _ = try? await provider.createEvent(event, in: calendarID)
        }

        var synced = event
        synced.remoteID = primary.remoteID
        synced.icsURL = primary.icsURL
        return synced
    }

    /// Recipient side: add the shared event to the local default calendar.
    @discardableResult
    public func addToMyCalendar(_ event: MeetingEvent) async throws -> SyncedEventRef {
        try await local.addToDefaultCalendar(event)
    }
}
