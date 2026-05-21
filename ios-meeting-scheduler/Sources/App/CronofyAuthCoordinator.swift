import AuthenticationServices
import UIKit
import ConveneKit

/// Runs Cronofy hosted auth in an `ASWebAuthenticationSession` and returns the
/// one-time `code` from the redirect. The code is exchanged for tokens by the
/// backend (which holds the client secret).
@MainActor
final class CronofyAuthCoordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var activeSession: ASWebAuthenticationSession?

    func authenticate(config: CronofyConfig) async throws -> String {
        let authSession = CronofyAuthSession(config: config)
        let callbackURL: URL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authSession.authorizationURL,
                callbackURLScheme: authSession.callbackScheme
            ) { url, error in
                if let url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: error ?? CronofyAuthError.malformedRedirect)
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.activeSession = session
            if !session.start() {
                continuation.resume(throwing: CronofyAuthError.malformedRedirect)
            }
        }
        activeSession = nil
        return try authSession.parseRedirect(callbackURL)
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        return scene?.keyWindow ?? ASPresentationAnchor()
    }
}
