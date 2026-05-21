import Foundation

/// Wire models for the Cronofy REST API. Field names mirror Cronofy's JSON.
enum CronofyAPI {
    struct CalendarsResponse: Decodable {
        let calendars: [Calendar]

        struct Calendar: Decodable {
            let providerName: String?
            let profileName: String?
            let calendarId: String
            let calendarName: String?
            let calendarReadonly: Bool?
            let calendarDeleted: Bool?
            let calendarPrimary: Bool?

            enum CodingKeys: String, CodingKey {
                case providerName = "provider_name"
                case profileName = "profile_name"
                case calendarId = "calendar_id"
                case calendarName = "calendar_name"
                case calendarReadonly = "calendar_readonly"
                case calendarDeleted = "calendar_deleted"
                case calendarPrimary = "calendar_primary"
            }
        }
    }

    /// Body for `POST /v1/calendars/{calendar_id}/events`.
    struct UpsertEventRequest: Encodable {
        let eventId: String
        let summary: String
        let description: String?
        let start: String
        let end: String
        let location: Location?
        let attendees: Attendees?

        struct Location: Encodable { let description: String }
        struct Attendees: Encodable { let invite: [Invitee] }
        struct Invitee: Encodable {
            let email: String
            let displayName: String?
            enum CodingKeys: String, CodingKey {
                case email
                case displayName = "display_name"
            }
        }

        enum CodingKeys: String, CodingKey {
            case eventId = "event_id"
            case summary, description, start, end, location, attendees
        }
    }
}
