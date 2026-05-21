import SwiftUI
import ConveneKit

struct RootView: View {
    @EnvironmentObject private var accounts: AccountStore

    var body: some View {
        NavigationStack {
            if accounts.isConnected {
                SettingsView()
            } else {
                ConnectAccountsView()
            }
        }
    }
}
