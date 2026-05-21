import XCTest
@testable import ConveneKit

final class PollEngineTests: XCTestCase {
    private func makePoll() -> Poll {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        return Poll(
            title: "Dinner",
            organizerName: "Dave",
            options: [
                TimeSlot(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, start: base),
                TimeSlot(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, start: base.addingTimeInterval(86_400)),
            ]
        )
    }

    func testNoVotesHasNoWinner() {
        XCTAssertNil(PollEngine.winningSlot(makePoll()))
        XCTAssertEqual(PollEngine.totalVotes(makePoll()), 0)
    }

    func testTallyCountsVotesPerSlot() {
        var poll = makePoll()
        let slotA = poll.options[0].id
        poll = poll.castingVote(voterID: "a", slotID: slotA)
        poll = poll.castingVote(voterID: "b", slotID: slotA)

        let tally = PollEngine.tally(poll)
        XCTAssertEqual(tally[0].count, 2)
        XCTAssertEqual(tally[1].count, 0)
    }

    func testRevotingReplacesPreviousVote() {
        var poll = makePoll()
        poll = poll.castingVote(voterID: "a", slotID: poll.options[0].id)
        poll = poll.castingVote(voterID: "a", slotID: poll.options[1].id)

        XCTAssertEqual(PollEngine.totalVotes(poll), 1)
        XCTAssertEqual(PollEngine.winningSlot(poll)?.id, poll.options[1].id)
    }

    func testTieBreaksTowardEarlierStart() {
        var poll = makePoll() // options[0] is earlier
        poll = poll.castingVote(voterID: "a", slotID: poll.options[0].id)
        poll = poll.castingVote(voterID: "b", slotID: poll.options[1].id)

        XCTAssertEqual(PollEngine.winningSlot(poll)?.id, poll.options[0].id)
    }
}
