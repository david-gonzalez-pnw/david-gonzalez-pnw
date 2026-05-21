import SwiftUI
import ConveneKit

struct SettingsView: View {
    @EnvironmentObject private var accounts: AccountStore

    var body: some View {
        List {
            Section {
                ForEach(accounts.accounts) { account in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.kind.displayName).font(.headline)
                            Text(account.email).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if account.isDefault {
                            Label("Default", systemImage: "star.fill")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.yellow)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { accounts.setDefault(account.id) }
                    .swipeActions {
                        Button(role: .destructive) {
                            accounts.disconnect(account.id)
                        } label: { Label("Disconnect", systemImage: "trash") }
                    }
                }
            } header: {
                Text("Connected calendars")
            } footer: {
                Text("Tap a calendar to make it the default — the source of truth that tracks who's attending.")
            }

            Section {
                ForEach(CalendarProviderKind.allCases) { kind in
                    Button {
                        Task { await accounts.connect(kind) }
                    } label: {
                        Label("Add \(kind.displayName)", systemImage: "plus")
                    }
                    .disabled(accounts.isWorking)
                }
            } header: {
                Text("Add another")
            }
        }
        .navigationTitle("Convene")
    }
}
