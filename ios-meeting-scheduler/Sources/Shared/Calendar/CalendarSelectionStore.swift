import Foundation

/// Persists the user's connected calendars and which one is the default
/// (source of truth), shared between the app and the extension via the App Group.
public enum CalendarSelectionStore {
    private static let calendarsKey = "convene.calendars"
    private static let defaultKey = "convene.defaultCalendarID"

    public static func calendars(_ defaults: UserDefaults? = ConveneConfig.sharedDefaults) -> [CalendarRef] {
        guard let data = (defaults ?? .standard).data(forKey: calendarsKey),
              let calendars = try? JSONCoders.decoder.decode([CalendarRef].self, from: data) else {
            return []
        }
        return calendars
    }

    public static func setCalendars(_ calendars: [CalendarRef], _ defaults: UserDefaults? = ConveneConfig.sharedDefaults) {
        let store = defaults ?? .standard
        if let data = try? JSONCoders.encoder.encode(calendars) {
            store.set(data, forKey: calendarsKey)
        }
    }

    public static func defaultCalendarID(_ defaults: UserDefaults? = ConveneConfig.sharedDefaults) -> String? {
        (defaults ?? .standard).string(forKey: defaultKey)
    }

    public static func setDefaultCalendarID(_ id: String, _ defaults: UserDefaults? = ConveneConfig.sharedDefaults) {
        (defaults ?? .standard).set(id, forKey: defaultKey)
    }

    public static func clear(_ defaults: UserDefaults? = ConveneConfig.sharedDefaults) {
        let store = defaults ?? .standard
        store.removeObject(forKey: calendarsKey)
        store.removeObject(forKey: defaultKey)
    }
}
