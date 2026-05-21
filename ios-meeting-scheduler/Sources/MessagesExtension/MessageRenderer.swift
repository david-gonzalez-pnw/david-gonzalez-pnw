import Foundation
import Messages
import ConveneKit

/// Builds interactive `MSMessage` bubbles for polls and events.
/// Bubbles created within a flow reuse the same `MSSession` so iMessage updates
/// one bubble in place (e.g. live vote tallies) rather than appending new ones.
enum MessageRenderer {
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    static func message(for poll: Poll, session: MSSession?) throws -> MSMessage {
        let message = MSMessage(session: session ?? MSSession())
        message.url = try MessageURLCodec.encode(.poll(poll))

        let layout = MSMessageTemplateLayout()
        layout.caption = poll.title
        let total = PollEngine.totalVotes(poll)
        layout.subcaption = total == 0
            ? "Tap to vote · \(poll.options.count) options"
            : "Tap to vote · \(total) vote\(total == 1 ? "" : "s")"
        if let winner = PollEngine.winningSlot(poll) {
            layout.trailingSubcaption = "Leading: \(dateFormatter.string(from: winner.start))"
        }
        message.layout = layout
        message.summaryText = "Poll: \(poll.title)"
        return message
    }

    static func message(for event: MeetingEvent, session: MSSession?) throws -> MSMessage {
        let message = MSMessage(session: session ?? MSSession())
        message.url = try MessageURLCodec.encode(.event(event))

        let layout = MSMessageTemplateLayout()
        layout.caption = event.title
        layout.subcaption = dateFormatter.string(from: event.start)
        if let location = event.location, !location.isEmpty {
            layout.trailingSubcaption = location
        }
        layout.trailingCaption = "Add to calendar"
        message.layout = layout
        message.summaryText = "Event: \(event.title)"
        return message
    }
}
