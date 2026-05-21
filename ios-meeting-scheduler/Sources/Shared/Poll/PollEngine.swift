import Foundation

/// Pure functions for tallying votes and picking a winning slot.
/// No UI, no I/O — fully unit-testable.
public enum PollEngine {
    public struct Tally: Equatable {
        public let slot: TimeSlot
        public let count: Int
    }

    /// Vote counts per slot, in the poll's option order.
    public static func tally(_ poll: Poll) -> [Tally] {
        poll.options.map { slot in
            Tally(slot: slot, count: poll.votes.filter { $0.slotID == slot.id }.count)
        }
    }

    /// The slot with the most votes. Ties break toward the earliest start time.
    /// Returns `nil` when there are no votes yet.
    public static func winningSlot(_ poll: Poll) -> TimeSlot? {
        let tallies = tally(poll).filter { $0.count > 0 }
        guard !tallies.isEmpty else { return nil }
        return tallies.max { lhs, rhs in
            if lhs.count != rhs.count { return lhs.count < rhs.count }
            return lhs.slot.start > rhs.slot.start // earlier start wins the tie
        }?.slot
    }

    public static func totalVotes(_ poll: Poll) -> Int {
        poll.votes.count
    }
}
