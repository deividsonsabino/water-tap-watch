import Foundation
import Combine

public final class GoalStore: ObservableObject {
    private let dailyGoalKey = "dailyHydrationGoal"

    @Published public var dailyGoal: Int {
        didSet { UserDefaults.standard.set(dailyGoal, forKey: dailyGoalKey) }
    }

    public init() {
        let stored = UserDefaults.standard.integer(forKey: dailyGoalKey)
        self.dailyGoal = stored > 0 ? stored : 2000
    }
}
