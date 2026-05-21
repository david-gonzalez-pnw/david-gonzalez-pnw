import UIKit
import SwiftUI
import Messages
import ConveneKit

/// Actions the hosted SwiftUI views call back into the extension with.
struct ExtensionActions {
    var sendPoll: (Poll, MSSession?) -> Void
    var sendEvent: (MeetingEvent, MSSession?) -> Void
    var requestExpanded: () -> Void
    var dismiss: () -> Void
}

final class MessagesViewController: MSMessagesAppViewController {
    private var hosting: UIViewController?

    // MARK: - Lifecycle

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        presentUI(for: conversation)
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        guard let conversation = activeConversation else { return }
        presentUI(for: conversation)
    }

    // MARK: - Routing

    private func presentUI(for conversation: MSConversation) {
        let actions = makeActions()
        let voterID = conversation.localParticipantIdentifier.uuidString
        let organizerName = "You"

        let root: AnyView
        if let selected = conversation.selectedMessage,
           let url = selected.url,
           let payload = try? MessageURLCodec.decode(url) {
            switch payload {
            case .poll(let poll):
                root = AnyView(PollVoteView(
                    poll: poll,
                    voterID: voterID,
                    session: selected.session,
                    actions: actions
                ))
            case .event(let event):
                root = AnyView(EventDetailView(event: event, actions: actions))
            }
        } else {
            root = AnyView(ComposeHomeView(
                organizerName: organizerName,
                actions: actions
            ))
        }

        host(root)
    }

    private func makeActions() -> ExtensionActions {
        ExtensionActions(
            sendPoll: { [weak self] poll, session in
                self?.send { try MessageRenderer.message(for: poll, session: session) }
            },
            sendEvent: { [weak self] event, session in
                self?.send { try MessageRenderer.message(for: event, session: session) }
            },
            requestExpanded: { [weak self] in
                self?.requestPresentationStyle(.expanded)
            },
            dismiss: { [weak self] in
                self?.dismiss()
            }
        )
    }

    private func send(_ build: () throws -> MSMessage) {
        guard let conversation = activeConversation else { return }
        do {
            let message = try build()
            conversation.insert(message) { error in
                if let error { NSLog("Convene insert failed: \(error.localizedDescription)") }
            }
            dismiss()
        } catch {
            NSLog("Convene message build failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Hosting

    private func host(_ view: AnyView) {
        hosting?.willMove(toParent: nil)
        hosting?.view.removeFromSuperview()
        hosting?.removeFromParent()

        let controller = UIHostingController(rootView: view)
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        controller.didMove(toParent: self)
        hosting = controller
    }
}
