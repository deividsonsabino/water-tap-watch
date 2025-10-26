import SwiftUI

struct ContentView: View {
    @EnvironmentObject var goalStore: GoalStore
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Daily Goal")
                    .font(.headline)

                GoalValueText(value: goalStore.dailyGoal)

                PrimaryButton(title: "Edit Goal") {
                    showEditor = true
                }
            }
            .padding()
            .navigationTitle("WaterTap")
        }
        .sheet(isPresented: $showEditor) {
            GoalEditorView(goalStore: goalStore)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GoalStore())
}
