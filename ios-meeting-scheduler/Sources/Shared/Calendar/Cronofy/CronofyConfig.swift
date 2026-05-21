import Foundation

/// Configuration for Cronofy, our unified calendar provider.
///
/// Cronofy brokers Google/Microsoft/Apple connections, so there are no
/// per-provider OAuth apps to register and no Google/Microsoft production
/// verification to pass — you create one application in the Cronofy dashboard
/// and use its client id/secret. The secret stays on the backend; the app only
/// ever holds short-lived access tokens.
///
/// Leave `clientID` empty to run the scaffold in offline (stub) mode.
public struct CronofyConfig: Equatable {
    /// Cronofy data centers. Pick the one your Cronofy account lives in.
    public enum DataCenter: String, Codable, CaseIterable, Equatable {
        case us, de, au, sg, uk

        public var apiHost: String {
            self == .us ? "api.cronofy.com" : "api-\(rawValue).cronofy.com"
        }
        public var appHost: String {
            self == .us ? "app.cronofy.com" : "app-\(rawValue).cronofy.com"
        }
    }

    public var clientID: String
    public var redirectURI: String
    /// Space-separated Cronofy scopes. These cover listing calendars and creating events.
    public var scope: String
    public var dataCenter: DataCenter

    public init(
        clientID: String,
        redirectURI: String,
        scope: String = "read_account read_events create_event delete_event",
        dataCenter: DataCenter = .us
    ) {
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.scope = scope
        self.dataCenter = dataCenter
    }

    public var apiBaseURL: URL { URL(string: "https://\(dataCenter.apiHost)")! }

    /// When false, the app runs against `StubCalendarSyncProvider` instead of hitting Cronofy.
    public var isConfigured: Bool { !clientID.isEmpty }

    /// Fill in `clientID` from the Cronofy dashboard and register `redirectURI`
    /// there. The custom scheme is intercepted by `ASWebAuthenticationSession`.
    public static let shared = CronofyConfig(
        clientID: "",
        redirectURI: "\(ConveneConfig.messageScheme)://oauth/cronofy"
    )
}
