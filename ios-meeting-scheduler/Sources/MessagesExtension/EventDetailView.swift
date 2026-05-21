import SwiftUI
import ConveneKit

/// Shown when someone taps an event bubble. One tap adds it to their calendar
/// via EventKit. Recipients without the app fall back to the `.ics` universal link.
struct EventDetailView: View {
    let event: MeetingEvent
    let actions: ExtensionActions

    @State private var status: Status = .idle

    enum Status: Equatable {
        case idle, adding, added, failed(String)
    }

    private let coordinator = CalendarSyncCoordinator(provider: StubCalendarSyncProvider())

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.title).font(.title2.bold())

            Label(Self.formatter.string(from: event.start), systemImage: "clock")
            if let location = event.location, !location.isEmpty {
                Label(location, systemImage: "mappin.and.ellipse")
            }

            Spacer()

            switch status {
            case .added:
                Label("Added to your calendar", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .failed(let message):
                Text(message).font(.footnote).foregroundStyle(.red)
                addButton
            default:
                addButton
            }
        }
        .padding()
    }

    private var addButton: some View {
        Button(action: add) {
            HStack {
                if status == .adding { ProgressView() }
                Text(status == .adding ? "Adding…" : "Add to my calendar")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(status == .adding)
    }

    private func add() {
        status = .adding
        Task {
            do {
                _ = try await coordinator.addToMyCalendar(event)
                await MainActor.run { status = .added }
            } catch {
                await MainActor.run { status = .failed(error.localizedDescription) }
            }
        }
    }
}
