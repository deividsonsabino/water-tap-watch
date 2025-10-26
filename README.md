// Hydration Tracker

import SwiftUI
import Combine

// GoalStore manages the daily hydration goal with persistence.
final class GoalStore: ObservableObject {
    @Published var dailyGoal: Int {
        didSet {
            UserDefaults.standard.set(dailyGoal, forKey: Self.dailyGoalKey)
        }
    }

    private static let dailyGoalKey = "dailyHydrationGoal"

    init() {
        let storedGoal = UserDefaults.standard.integer(forKey: Self.dailyGoalKey)
        self.dailyGoal = storedGoal > 0 ? storedGoal : 2000 // Default 2000ml
    }
}

@main
struct HydrationTrackerApp: App {
    @StateObject private var goalStore = GoalStore()

    var body: some Scene {
        WindowGroup {
            GoalEditor()
                .environmentObject(goalStore)
        }
    }
}

struct GoalEditor: View {
    @EnvironmentObject var goalStore: GoalStore
    @State private var inputText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Daily Hydration Goal")) {
                    HStack {
                        TextField("Enter goal (ml)", text: $inputText)
                            .keyboardType(.numberPad)
                            .onChange(of: inputText) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    inputText = filtered
                                }
                            }
                            .onSubmit {
                                applyInput()
                            }
                            .submitLabel(.done)

                        Button("Set") {
                            applyInput()
                        }
                        .disabled(!isValidInput)
                    }
                    Text("Current goal: \(goalStore.dailyGoal) ml")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Goal Editor")
            .onAppear {
                inputText = "\(goalStore.dailyGoal)"
            }
        }
    }

    private var isValidInput: Bool {
        if let value = Int(inputText), value > 0 { return true }
        return false
    }

    private func applyInput() {
        guard let value = Int(inputText), value > 0 else { return }
        goalStore.dailyGoal = value
        // Optionally dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
