import SwiftUI
import ConveneKit

@main
struct ConveneApp: App {
    @StateObject private var accounts = AccountStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(accounts)
        }
    }
}
