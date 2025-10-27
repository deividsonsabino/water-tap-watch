import SwiftUI

@main
struct WaterTap_iOSApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var goalStore = {
        let suiteName = "group.com.deivao.watertap" // mesmo ID usado no Watch
        let storage = UserDefaults(suiteName: suiteName) ?? .standard
        return GoalStore(storage: storage)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(goalStore)
                .onAppear {
                    _ = ConnectivityService.shared // ativa
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
}
