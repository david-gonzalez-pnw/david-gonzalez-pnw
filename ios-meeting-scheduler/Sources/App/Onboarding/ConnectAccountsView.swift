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
            Text("Connect your calendar")
                .font(.title2.bold())
            Text("Convene uses Cronofy to connect Google, Outlook, or iCloud in one step — no per-provider setup. Polls happen in iMessage; agreed meetings sync to your calendar.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task { await accounts.connect() }
            } label: {
                Label("Connect a calendar", systemImage: "link")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(accounts.isWorking)
            .padding(.horizontal)

            if accounts.isWorking {
                ProgressView()
            }

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
