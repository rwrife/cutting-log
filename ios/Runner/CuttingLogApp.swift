import SwiftUI

@main
struct CuttingLogApp: App {
    @StateObject private var store = JournalStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .tint(Color(red: 0.22, green: 0.42, blue: 0.13))
        }
    }
}
