import Foundation

public enum RSVPStatus: String, Codable, Equatable {
    case needsAction
    case accepted
    case declined
    case tentative
}

public struct Attendee: Codable, Equatable, Identifiable {
    /// Email when known, otherwise an opaque conversation-scoped id.
    public var id: String
    public var name: String?
    public var email: String?
    public var rsvp: RSVPStatus

    public init(id: String, name: String? = nil, email: String? = nil, rsvp: RSVPStatus = .needsAction) {
        self.id = id
        self.name = name
        self.email = email
        self.rsvp = rsvp
    }
}

/// A confirmed meeting, derived from a poll's winning slot, that syncs to calendars
/// and is shared back into the thread as a tappable bubble.
public struct MeetingEvent: Codable, Identifiable, Equatable {
    public var id: UUID
    public var title: String
    public var start: Date
    public var end: Date
    public var location: String?
    public var notes: String?
    public var organizer: Attendee
    public var attendees: [Attendee]
    /// Universal link to an `.ics` so recipients without the app can still add it.
    public var icsURL: URL?
    /// Reference assigned by the sync provider once the event exists remotely.
    public var remoteID: String?

    public init(
        id: UUID = UUID(),
        title: String,
        start: Date,
        end: Date,
        location: String? = nil,
        notes: String? = nil,
        organizer: Attendee,
        attendees: [Attendee] = [],
        icsURL: URL? = nil,
        remoteID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.location = location
        self.notes = notes
        self.organizer = organizer
        self.attendees = attendees
        self.icsURL = icsURL
        self.remoteID = remoteID
    }

    public init(title: String, slot: TimeSlot, organizer: Attendee, attendees: [Attendee] = []) {
        self.init(
            title: title,
            start: slot.start,
            end: slot.end,
            organizer: organizer,
            attendees: attendees
        )
    }
}
