import SwiftUI
import ConveneKit

struct SettingsView: View {
    @EnvironmentObject private var accounts: AccountStore

    var body: some View {
        List {
            Section {
                ForEach(accounts.calendars) { calendar in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(calendar.title).font(.headline)
                            if let account = calendar.accountName {
                                Text(account).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if calendar.id == accounts.defaultCalendarID {
                            Label("Default", systemImage: "star.fill")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.yellow)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { accounts.setDefault(calendar.id) }
                }
            } header: {
                Text("Calendars")
            } footer: {
                Text("Tap a calendar to make it the default — the source of truth that owns the attendee list and tracks RSVPs.")
            }

            Section {
                Button(role: .destructive) {
                    accounts.disconnect()
                } label: {
                    Label("Disconnect", systemImage: "xmark.circle")
                }
            }
        }
        .navigationTitle("Convene")
    }
}
