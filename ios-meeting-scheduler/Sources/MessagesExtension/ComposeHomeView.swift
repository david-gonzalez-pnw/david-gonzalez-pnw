import SwiftUI
import ConveneKit

/// Entry screen shown when the user opens Convene with no message selected.
struct ComposeHomeView: View {
    let organizerName: String
    let actions: ExtensionActions
    var backend: ConveneBackendClient = StubBackendClient()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        PollComposeView(organizerName: organizerName, actions: actions)
                    } label: {
                        Label("New date poll", systemImage: "chart.bar.doc.horizontal")
                    }
                    NavigationLink {
                        EventComposeView(organizerName: organizerName, actions: actions, backend: backend)
                    } label: {
                        Label("Schedule an event", systemImage: "calendar.badge.plus")
                    }
                } footer: {
                    Text("Poll the group for times, then turn the winning slot into an event everyone can add with one tap.")
                }
            }
            .navigationTitle("Convene")
            .onAppear { actions.requestExpanded() }
        }
    }
}
