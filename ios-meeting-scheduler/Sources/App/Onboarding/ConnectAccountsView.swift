import SwiftUI
import ConveneKit

struct ConnectAccountsView: View {
    @EnvironmentObject private var accounts: AccountStore

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("Connect your calendars")
                .font(.title2.bold())
            Text("Convene polls your group in iMessage, then syncs the agreed meeting to every calendar you connect.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(CalendarProviderKind.allCases) { kind in
                    Button {
                        Task { await accounts.connect(kind) }
                    } label: {
                        Label("Connect \(kind.displayName)", systemImage: "link")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(accounts.isWorking)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Convene")
        .alert("Couldn't connect", isPresented: .constant(accounts.errorMessage != nil)) {
            Button("OK") { accounts.errorMessage = nil }
        } message: {
            Text(accounts.errorMessage ?? "")
        }
    }
}
