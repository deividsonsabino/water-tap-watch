import SwiftUI
import Foundation
import WatchKit

@main
struct WaterTapWatchApp: App {
    @StateObject private var goalStore: GoalStore = {
        let suiteName = "group.com.deivao.watertap"
        let storage = UserDefaults(suiteName: suiteName) ?? .standard
        return GoalStore(storage: storage)
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(goalStore)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var goalStore: GoalStore

    var body: some View {
        ContentView()
            .onAppear {
                _ = ConnectivityService.shared  // activate WCSession
                goalStore.reload()              // ensure latest local value
            }
            .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillEnterForegroundNotification)) { _ in
                goalStore.reload()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveGoalUpdate)) { note in
                if let goal = note.object as? Int, goal > 0, goal != goalStore.dailyGoal {
                    goalStore.dailyGoal = goal
                }
            }
            .onChange(of: goalStore.dailyGoal) { newGoal in
                ConnectivityService.shared.send(goal: newGoal)
            }
    }
}
