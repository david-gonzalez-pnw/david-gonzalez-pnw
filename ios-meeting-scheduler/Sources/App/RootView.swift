import SwiftUI
import ConveneKit

struct RootView: View {
    @EnvironmentObject private var accounts: AccountStore

    var body: some View {
        NavigationStack {
            if accounts.accounts.isEmpty {
                ConnectAccountsView()
            } else {
                SettingsView()
            }
        }
    }
}
