import Foundation

public enum CalendarProviderKind: String, Codable, CaseIterable, Identifiable {
    case google
    case outlook
    case icloud

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .google: return "Google"
        case .outlook: return "Outlook"
        case .icloud: return "iCloud"
        }
    }
}

/// A calendar account the user has connected via OAuth (or, for iCloud, on-device).
public struct ConnectedAccount: Codable, Equatable, Identifiable {
    public var id: String
    public var kind: CalendarProviderKind
    public var email: String
    public var isDefault: Bool

    public init(id: String, kind: CalendarProviderKind, email: String, isDefault: Bool = false) {
        self.id = id
        self.kind = kind
        self.email = email
        self.isDefault = isDefault
    }
}
