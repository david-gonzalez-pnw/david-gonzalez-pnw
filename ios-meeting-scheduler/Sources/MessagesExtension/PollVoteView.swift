import SwiftUI
import Messages
import ConveneKit

/// Shown when a recipient (or the organizer) taps a poll bubble.
/// Voting sends an updated poll on the same `MSSession`, so the thread keeps a
/// single live bubble. When there's a leader, the organizer can turn it into an event.
struct PollVoteView: View {
    let poll: Poll
    let voterID: String
    let session: MSSession?
    let actions: ExtensionActions

    private var myVote: UUID? { poll.votes.first(where: { $0.voterID == voterID })?.slotID }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationStack {
            List {
                Section(poll.title) {
                    ForEach(PollEngine.tally(poll), id: \.slot.id) { tally in
                        Button {
                            let updated = poll.castingVote(voterID: voterID, slotID: tally.slot.id)
                            actions.sendPoll(updated, session)
                        } label: {
                            HStack {
                                Image(systemName: myVote == tally.slot.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(myVote == tally.slot.id ? Color.accentColor : .secondary)
                                Text(Self.formatter.string(from: tally.slot.start))
                                Spacer()
                                Text("\(tally.count)").monospacedDigit().foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let winner = PollEngine.winningSlot(poll) {
                    Section {
                        NavigationLink {
                            EventComposeView(
                                organizerName: poll.organizerName,
                                actions: actions,
                                prefillTitle: poll.title,
                                prefillSlot: winner
                            )
                        } label: {
                            Label("Create event for the winning time", systemImage: "calendar.badge.plus")
                        }
                    } footer: {
                        Text("Leading: \(Self.formatter.string(from: winner.start))")
                    }
                }
            }
            .navigationTitle("Vote")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
