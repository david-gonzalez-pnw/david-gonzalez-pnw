import Foundation

/// Wire DTOs for the Convene backend. The backend's only job is to broker
/// Cronofy OAuth: it holds the Cronofy client secret, exchanges/refreshes
/// tokens, and receives RSVP push notifications. All calendar reads/writes
/// happen client-side via `CronofyCalendarSyncProvider` using these tokens.
public enum API {

    // POST /v1/cronofy/token  — exchange the hosted-auth code for tokens.
    // The backend keeps the refresh token; the app receives only a short-lived access token.
    public struct CronofyExchangeRequest: Codable, Equatable {
        public var code: String
        public var redirectURI: String
        public init(code: String, redirectURI: String) {
            self.code = code
            self.redirectURI = redirectURI
        }
    }

    public struct CronofyExchangeResponse: Codable, Equatable {
        public var accessToken: String
        public var expiresIn: Int
        public var accountID: String
        public var providerName: String?
        public init(accessToken: String, expiresIn: Int, accountID: String, providerName: String? = nil) {
            self.accessToken = accessToken
            self.expiresIn = expiresIn
            self.accountID = accountID
            self.providerName = providerName
        }
    }

    // POST /v1/cronofy/token/refresh  — backend refreshes using its stored refresh token.
    public struct CronofyRefreshResponse: Codable, Equatable {
        public var accessToken: String
        public var expiresIn: Int
        public init(accessToken: String, expiresIn: Int) {
            self.accessToken = accessToken
            self.expiresIn = expiresIn
        }
    }

    // Webhook the backend receives from Cronofy when attendee status changes.
    public struct RSVPWebhook: Codable, Equatable {
        public var remoteID: String
        public var attendees: [Attendee]
        public init(remoteID: String, attendees: [Attendee]) {
            self.remoteID = remoteID
            self.attendees = attendees
        }
    }
}
