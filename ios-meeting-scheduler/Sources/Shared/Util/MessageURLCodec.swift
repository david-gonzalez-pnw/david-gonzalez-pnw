import Foundation

/// Round-trips a `ConveneMessage` to/from the `URL` stored on an `MSMessage`.
///
/// Wire format: `convene://message?v=1&kind=poll&payload=<json>`
/// The JSON payload is URL-encoded automatically by `URLComponents`. Keeping the
/// `kind` and `v` as separate query items lets the extension branch and
/// version-check without decoding the whole blob.
public enum MessageURLCodec {
    public enum CodecError: Error, Equatable {
        case missingPayload
        case unsupportedVersion(Int)
        case malformedURL
    }

    public static func encode(_ message: ConveneMessage) throws -> URL {
        let data = try JSONCoders.encoder.encode(message)
        let json = String(decoding: data, as: UTF8.self)

        var components = URLComponents()
        components.scheme = ConveneConfig.messageScheme
        components.host = "message"
        components.queryItems = [
            URLQueryItem(name: "v", value: String(ConveneConfig.payloadVersion)),
            URLQueryItem(name: "kind", value: message.kind.rawValue),
            URLQueryItem(name: "payload", value: json),
        ]
        guard let url = components.url else { throw CodecError.malformedURL }
        return url
    }

    public static func decode(_ url: URL) throws -> ConveneMessage {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else {
            throw CodecError.malformedURL
        }

        if let versionString = items.first(where: { $0.name == "v" })?.value,
           let version = Int(versionString),
           version > ConveneConfig.payloadVersion {
            throw CodecError.unsupportedVersion(version)
        }

        guard let json = items.first(where: { $0.name == "payload" })?.value,
              let data = json.data(using: .utf8) else {
            throw CodecError.missingPayload
        }

        return try JSONCoders.decoder.decode(ConveneMessage.self, from: data)
    }
}
