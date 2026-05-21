import SwiftUI
import ConveneKit

/// Compose a date/time poll and send it into the thread.
struct PollComposeView: View {
    let organizerName: String
    let actions: ExtensionActions

    @State private var title = ""
    @State private var slots: [TimeSlot] = [
        TimeSlot(start: PollComposeView.nextHour()),
    ]

    var body: some View {
        Form {
            Section("What's the plan?") {
                TextField("e.g. Dinner this weekend", text: $title)
            }

            Section("Proposed times") {
                ForEach($slots) { $slot in
                    DatePicker(
                        "Option",
                        selection: $slot.start,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                .onDelete { slots.remove(atOffsets: $0) }

                Button {
                    slots.append(TimeSlot(start: (slots.last?.start ?? Date()).addingTimeInterval(3600)))
                } label: {
                    Label("Add another time", systemImage: "plus")
                }
            }

            Section {
                Button {
                    let poll = Poll(
                        title: title.isEmpty ? "Let's pick a time" : title,
                        organizerName: organizerName,
                        options: slots
                    )
                    actions.sendPoll(poll, nil)
                } label: {
                    Text("Send poll").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(slots.isEmpty)
            }
        }
        .navigationTitle("New poll")
        .navigationBarTitleDisplayMode(.inline)
    }

    private static func nextHour() -> Date {
        let cal = Calendar.current
        let next = cal.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        return cal.date(bySetting: .minute, value: 0, of: next) ?? next
    }
}
