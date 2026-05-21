import Foundation

public enum CronofyAuthError: Error, Equatable {
    case missingCode
    case stateMismatch
    case malformedRedirect
}

/// Builds the Cronofy hosted-auth URL and parses the redirect. Pure and
/// secret-free — safe to run on the client. The returned `code` is exchanged for
/// tokens by the backend (which holds the client secret).
public struct CronofyAuthSession {
    public let config: CronofyConfig
    public let state: String

    public init(config: CronofyConfig, state: String = UUID().uuidString) {
        self.config = config
        self.state = state
    }

    public var authorizationURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = config.dataCenter.appHost
        components.path = "/oauth/authorize"
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "scope", value: config.scope),
            URLQueryItem(name: "state", value: state),
        ]
        return components.url!
    }

    /// Callback scheme `ASWebAuthenticationSession` listens for (e.g. "convene").
    public var callbackScheme: String? {
        URLComponents(string: config.redirectURI)?.scheme
    }

    public func parseRedirect(_ url: URL) throws -> String {
        guard let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            throw CronofyAuthError.malformedRedirect
        }
        if let returnedState = items.first(where: { $0.name == "state" })?.value,
           returnedState != state {
            throw CronofyAuthError.stateMismatch
        }
        guard let code = items.first(where: { $0.name == "code" })?.value, !code.isEmpty else {
            throw CronofyAuthError.missingCode
        }
        return code
    }
}
