import Foundation

/// Identifies a calendar exposed by a provider (local EventKit or a remote unified API).
public struct CalendarRef: Codable, Equatable, Identifiable {
    public var id: String
    public var title: String
    public var accountName: String?
    public var allowsModification: Bool

    public init(id: String, title: String, accountName: String? = nil, allowsModification: Bool = true) {
        self.id = id
        self.title = title
        self.accountName = accountName
        self.allowsModification = allowsModification
    }
}

/// Reference to an event after it has been created in a provider.
public struct SyncedEventRef: Codable, Equatable {
    public var remoteID: String
    public var calendarID: String
    public var icsURL: URL?

    public init(remoteID: String, calendarID: String, icsURL: URL? = nil) {
        self.remoteID = remoteID
        self.calendarID = calendarID
        self.icsURL = icsURL
    }
}

public enum CalendarSyncError: Error, Equatable {
    case accessDenied
    case calendarNotFound
    case unsupported(String)
    case provider(String)
}

/// The single abstraction every calendar backend conforms to.
///
/// On-device iCloud/local uses `EventKitCalendarService`. Cross-provider sync and
/// participant/RSVP tracking are fulfilled by a remote implementation
/// (`Cronofy` / `Nylas` / `Composio`) behind this same protocol — see ARCHITECTURE.md §4.
public protocol CalendarSyncProvider {
    /// Calendars the user can write to.
    func availableCalendars() async throws -> [CalendarRef]

    /// Creates `event` on `calendarID` (the "source of truth" / default calendar)
    /// and returns the remote reference.
    func createEvent(_ event: MeetingEvent, in calendarID: String) async throws -> SyncedEventRef

    /// Records an attendee's RSVP. Not all providers support this (EventKit does not).
    func updateRSVP(remoteID: String, attendee: Attendee, status: RSVPStatus) async throws
}
