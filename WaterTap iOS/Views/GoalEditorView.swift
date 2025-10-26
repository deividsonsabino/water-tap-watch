import SwiftUI

struct GoalEditorView: View {
    @ObservedObject var goalStore: GoalStore
    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Hydration Goal") {
                    HStack {
                        TextField("Enter goal (ml)", text: $inputText)
                            .keyboardType(.numberPad)
                            .onChange(of: inputText) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue { inputText = filtered }
                            }

                        PrimaryButton(title: "Set") { apply() }
                            .disabled(!isValid)
                    }

                    Text("Current goal: \(goalStore.dailyGoal) ml")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                        .accessibilityLabel("Current goal is \(goalStore.dailyGoal) milliliters")
                }
            }
            .navigationTitle("Edit Goal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { apply() }.disabled(!isValid) }
            }
            .onAppear { inputText = "\(goalStore.dailyGoal)" }
        }
    }

    private var isValid: Bool {
        if let value = Int(inputText), value > 0 { return true }
        return false
    }

    private func apply() {
        guard let value = Int(inputText), value > 0 else { return }
        goalStore.dailyGoal = value
        dismiss()
    }
}
