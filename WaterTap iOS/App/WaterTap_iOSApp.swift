import SwiftUI

@main
struct WaterTap_iOSApp: App {
    @StateObject private var goalStore = GoalStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(goalStore)
        }
    }
}
