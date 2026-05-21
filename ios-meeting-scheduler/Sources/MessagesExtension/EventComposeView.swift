import SwiftUI
import ConveneKit

/// Confirm event details, sync to the organizer's calendars via Cronofy (or the
/// stub when offline), then share a tappable event bubble into the thread.
struct EventComposeView: View {
    let organizerName: String
    let actions: ExtensionActions
    var prefillTitle: String?
    var prefillSlot: TimeSlot?

    private let coordinator = CalendarSyncCoordinator.makeDefault()
    /// Source-of-truth calendar chosen in the host app; falls back to a demo calendar offline.
    private let defaultCalendarID = CalendarSelectionStore.defaultCalendarID()
        ?? StubCalendarSyncProvider.demoCalendars.first?.id
        ?? "default"

    @State private var title: String
    @State private var start: Date
    @State private var durationMinutes: Int
    @State private var location: String = ""
    @State private var isSyncing = false
    @State private var errorMessage: String?

    init(
        organizerName: String,
        actions: ExtensionActions,
        prefillTitle: String? = nil,
        prefillSlot: TimeSlot? = nil
    ) {
        self.organizerName = organizerName
        self.actions = actions
        self.prefillTitle = prefillTitle
        self.prefillSlot = prefillSlot
        _title = State(initialValue: prefillTitle ?? "")
        _start = State(initialValue: prefillSlot?.start ?? Date().addingTimeInterval(3600))
        _durationMinutes = State(initialValue: prefillSlot?.durationMinutes ?? 60)
    }

    var body: some View {
        Form {
            Section("Event") {
                TextField("Title", text: $title)
                DatePicker("Starts", selection: $start, displayedComponents: [.date, .hourAndMinute])
                Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 15...480, step: 15)
                TextField("Location (optional)", text: $location)
            }

            Section {
                Button(action: createAndShare) {
                    HStack {
                        if isSyncing { ProgressView() }
                        Text(isSyncing ? "Syncing…" : "Create & share").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSyncing || title.isEmpty)
            } footer: {
                Text("Synced to your calendars via Cronofy, then shared here so everyone can add it with one tap.")
            }
        }
        .navigationTitle("New event")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't create event", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func createAndShare() {
        let organizer = Attendee(id: "organizer", name: organizerName)
        let event = MeetingEvent(
            id: UUID(),
            title: title,
            start: start,
            end: start.addingTimeInterval(TimeInterval(durationMinutes * 60)),
            location: location.isEmpty ? nil : location,
            organizer: organizer
        )

        isSyncing = true
        Task {
            do {
                let synced = try await coordinator.confirmAndSync(event, defaultCalendarID: defaultCalendarID)
                await MainActor.run {
                    isSyncing = false
                    actions.sendEvent(synced, nil)
                }
            } catch {
                await MainActor.run {
                    isSyncing = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
