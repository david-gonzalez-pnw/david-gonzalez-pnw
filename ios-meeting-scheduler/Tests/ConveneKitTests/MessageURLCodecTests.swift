import XCTest
@testable import ConveneKit

final class MessageURLCodecTests: XCTestCase {
    func testPollRoundTrips() throws {
        let poll = Poll(
            title: "Dinner",
            organizerName: "Dave",
            options: [TimeSlot(start: Date(timeIntervalSince1970: 1_700_000_000))]
        )
        let url = try MessageURLCodec.encode(.poll(poll))
        let decoded = try MessageURLCodec.decode(url)

        guard case .poll(let result) = decoded else { return XCTFail("expected poll") }
        XCTAssertEqual(result.id, poll.id)
        XCTAssertEqual(result.title, poll.title)
        XCTAssertEqual(result.options.first?.id, poll.options.first?.id)
    }

    func testEventRoundTrips() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let event = MeetingEvent(
            title: "Sync",
            start: start,
            end: start.addingTimeInterval(3600),
            location: "Cafe",
            organizer: Attendee(id: "organizer", name: "Dave")
        )
        let url = try MessageURLCodec.encode(.event(event))
        let decoded = try MessageURLCodec.decode(url)

        guard case .event(let result) = decoded else { return XCTFail("expected event") }
        XCTAssertEqual(result.id, event.id)
        XCTAssertEqual(result.location, "Cafe")
        XCTAssertEqual(result.end, event.end)
    }

    func testNewerVersionIsRejected() throws {
        let poll = Poll(title: "x", organizerName: "y", options: [])
        var url = try MessageURLCodec.encode(.poll(poll))
        url = URL(string: url.absoluteString.replacingOccurrences(of: "v=1", with: "v=99"))!

        XCTAssertThrowsError(try MessageURLCodec.decode(url)) { error in
            XCTAssertEqual(error as? MessageURLCodec.CodecError, .unsupportedVersion(99))
        }
    }

    func testMissingPayloadThrows() {
        let url = URL(string: "convene://message?v=1&kind=poll")!
        XCTAssertThrowsError(try MessageURLCodec.decode(url)) { error in
            XCTAssertEqual(error as? MessageURLCodec.CodecError, .missingPayload)
        }
    }
}
