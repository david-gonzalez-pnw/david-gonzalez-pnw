import Foundation

/// Shared JSON coders configured for ISO-8601 dates, used across models, the
/// message codec, and the backend client so wire formats stay consistent.
public enum JSONCoders {
    public static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    public static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
