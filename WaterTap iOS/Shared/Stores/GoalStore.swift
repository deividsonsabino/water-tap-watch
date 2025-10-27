import Foundation
import Combine

// A lightweight abstraction over key-value storage to enable testing and flexibility
public protocol KeyValueStoring {
    func integer(forKey defaultName: String) -> Int
    func set(_ value: Any?, forKey defaultName: String)
}

// Make UserDefaults conform to KeyValueStoring
extension UserDefaults: KeyValueStoring {}

public final class GoalStore: ObservableObject {
    private let dailyGoalKey = "dailyHydrationGoal"
    private let storage: KeyValueStoring

    @Published public var dailyGoal: Int {
        didSet { storage.set(dailyGoal, forKey: dailyGoalKey) }
    }

    public init(storage: KeyValueStoring = UserDefaults.standard) {
        self.storage = storage
        let stored = storage.integer(forKey: dailyGoalKey)
        self.dailyGoal = stored > 0 ? stored : 2000
    }

    // Reload when app becomes active (iOS/watchOS)
    public func reload() {
        let stored = storage.integer(forKey: dailyGoalKey)
        let value = stored > 0 ? stored : 2000
        if value != dailyGoal {
            dailyGoal = value
        }
    }
}
