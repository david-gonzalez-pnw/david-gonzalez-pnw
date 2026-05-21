import Foundation

/// The typed payload carried by an interactive iMessage bubble.
/// Encoded into `MSMessage.url` by `MessageURLCodec`.
public enum ConveneMessage: Codable, Equatable {
    case poll(Poll)
    case event(MeetingEvent)

    public enum Kind: String, Codable {
        case poll
        case event
    }

    public var kind: Kind {
        switch self {
        case .poll: return .poll
        case .event: return .event
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind, poll, event
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .poll:
            self = .poll(try container.decode(Poll.self, forKey: .poll))
        case .event:
            self = .event(try container.decode(MeetingEvent.self, forKey: .event))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        switch self {
        case .poll(let poll):
            try container.encode(poll, forKey: .poll)
        case .event(let event):
            try container.encode(event, forKey: .event)
        }
    }
}
