import Foundation

/// Wire DTOs for the future Convene backend. Documenting the contract as code
/// keeps the client and (eventual) server in sync. The backend brokers OAuth and
/// fronts the unified calendar provider (Cronofy / Nylas / Composio).
public enum API {

    // POST /v1/auth/{provider}/exchange
    public struct AuthExchangeRequest: Codable, Equatable {
        public var provider: CalendarProviderKind
        public var authorizationCode: String
        public var redirectURI: String
        public init(provider: CalendarProviderKind, authorizationCode: String, redirectURI: String) {
            self.provider = provider
            self.authorizationCode = authorizationCode
            self.redirectURI = redirectURI
        }
    }

    public struct AuthExchangeResponse: Codable, Equatable {
        public var account: ConnectedAccount
        public var calendars: [CalendarRef]
        public init(account: ConnectedAccount, calendars: [CalendarRef]) {
            self.account = account
            self.calendars = calendars
        }
    }

    // POST /v1/events
    public struct CreateEventRequest: Codable, Equatable {
        public var event: MeetingEvent
        public var defaultCalendarID: String
        public var mirrorCalendarIDs: [String]
        public init(event: MeetingEvent, defaultCalendarID: String, mirrorCalendarIDs: [String] = []) {
            self.event = event
            self.defaultCalendarID = defaultCalendarID
            self.mirrorCalendarIDs = mirrorCalendarIDs
        }
    }

    public struct CreateEventResponse: Codable, Equatable {
        public var ref: SyncedEventRef
        public init(ref: SyncedEventRef) { self.ref = ref }
    }

    // POST /v1/events/{remoteID}/rsvp
    public struct RSVPRequest: Codable, Equatable {
        public var attendee: Attendee
        public var status: RSVPStatus
        public init(attendee: Attendee, status: RSVPStatus) {
            self.attendee = attendee
            self.status = status
        }
    }

    // Webhook payload pushed to the backend by the provider when RSVP changes.
    public struct RSVPWebhook: Codable, Equatable {
        public var remoteID: String
        public var attendees: [Attendee]
        public init(remoteID: String, attendees: [Attendee]) {
            self.remoteID = remoteID
            self.attendees = attendees
        }
    }
}
