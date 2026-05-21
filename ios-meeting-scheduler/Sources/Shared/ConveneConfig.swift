import Foundation

/// Shared identifiers used by both the host app and the iMessage extension.
public enum ConveneConfig {
    /// App Group used to share state (connected accounts, default calendar) between the app and the extension.
    public static let appGroupID = "group.com.davidgonzalez.convene"

    /// Shared Keychain access group where provider tokens live so the extension can read them.
    public static let keychainAccessGroup = "com.davidgonzalez.convene"

    /// Host used for the `.ics` "add to calendar" universal-link fallback (recipients without the app).
    public static let universalLinkHost = "convene.example.com"

    /// URL scheme component identifying a Convene interactive message payload.
    public static let messageScheme = "convene"

    /// Payload version, bumped when the message wire format changes.
    public static let payloadVersion = 1

    public static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
}
