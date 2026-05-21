import Foundation

/// A candidate meeting time the group can vote on.
public struct TimeSlot: Codable, Identifiable, Equatable, Hashable {
    public var id: UUID
    public var start: Date
    public var durationMinutes: Int

    public init(id: UUID = UUID(), start: Date, durationMinutes: Int = 60) {
        self.id = id
        self.start = start
        self.durationMinutes = durationMinutes
    }

    public var end: Date { start.addingTimeInterval(TimeInterval(durationMinutes * 60)) }
}

/// One participant's vote for a single slot. `voterID` is an opaque, stable per-conversation identifier.
public struct Vote: Codable, Equatable, Hashable {
    public var voterID: String
    public var slotID: UUID

    public init(voterID: String, slotID: UUID) {
        self.voterID = voterID
        self.slotID = slotID
    }
}

/// A date/time poll shared into an iMessage thread.
public struct Poll: Codable, Identifiable, Equatable {
    public var id: UUID
    public var title: String
    public var organizerName: String
    public var options: [TimeSlot]
    public var votes: [Vote]
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        organizerName: String,
        options: [TimeSlot],
        votes: [Vote] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.organizerName = organizerName
        self.options = options
        self.votes = votes
        self.createdAt = createdAt
    }

    /// Returns a copy with `voterID`'s vote set to `slotID` (one vote per voter; re-voting replaces).
    public func castingVote(voterID: String, slotID: UUID) -> Poll {
        var copy = self
        copy.votes.removeAll { $0.voterID == voterID }
        copy.votes.append(Vote(voterID: voterID, slotID: slotID))
        return copy
    }
}
