import SwiftUI

// Design System (lightweight)
private enum DS {
    enum Spacing {
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }
    enum Radius {
        static let card: CGFloat = 16
    }
    enum Shadow {
        static let card: CGFloat = 4
    }
}

struct SurfaceCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            content()
        }
        .padding(DS.Spacing.l)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                .strokeBorder(.separator.opacity(0.2))
        }
        .shadow(radius: DS.Shadow.card, y: 2)
    }
}

struct ContentView: View {
    @EnvironmentObject var goalStore: GoalStore
    @State private var showEditor = false
    @State private var intakeMl: Int = 0
    
    private var progress: Double {
        let goal = max(1, goalStore.dailyGoal)
        return min(1, Double(intakeMl) / Double(goal))
    }
    
    private func add(_ amount: Int) {
        let goal = max(1, goalStore.dailyGoal)
        intakeMl = min(intakeMl + amount, goal) // não passa da meta
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func resetIntake() {
        intakeMl = 0
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        Text("Stay hydrated")
                            .font(.largeTitle.bold())
                        Text("Set your daily water goal and track your progress.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, DS.Spacing.m)

                    // Goal Card
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: DS.Spacing.l) {
                            Text("Daily Goal")
                                .font(.headline)
                            
                            WaterRingView(progress: progress)
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .padding(.top, DS.Spacing.s)
                            HStack(spacing: 12) {
                                PrimaryButton(title: "+200 ml") { add(200) }
                                    .accessibilityLabel("Add two hundred milliliters")

                                PrimaryButton(title: "+300 ml") { add(300) }
                                    .accessibilityLabel("Add three hundred milliliters")
                            }
                            .frame(maxWidth: .infinity)
                            VStack(spacing: DS.Spacing.s) {
                                Text("\(intakeMl) ml of \(goalStore.dailyGoal) ml")
                                    .font(.headline)
                                    .monospacedDigit()
                                    .accessibilityLabel("You have consumed \(intakeMl) milliliters out of \(goalStore.dailyGoal)")

                                Button("Reset") {
                                    resetIntake()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                                .disabled(intakeMl == 0)
                                .accessibilityLabel("Reset daily intake")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, DS.Spacing.s)

                            GoalValueText(value: goalStore.dailyGoal)

                            PrimaryButton(title: "Edit Goal") {
                                showEditor = true
                            }
                            .frame(maxWidth: .infinity, alignment: .leadingFirstTextBaseline)

                            Text("You can change this at any time. Default is 2000 ml.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.l)
                .padding(.bottom, DS.Spacing.xl)
            }
        }
        .sheet(isPresented: $showEditor) {
            // Fixed parameter label here
            GoalEditorView(goalStore: goalStore)
        }
        .onChange(of: intakeMl) { newValue in
            let goal = max(1, goalStore.dailyGoal)
            let progress = min(1, Double(newValue) / Double(goal))
            ConnectivityService.shared.sendProgress(percentage: progress)
            ConnectivityService.shared.sendIntake(ml: Double(newValue))
        }
        .onChange(of: goalStore.dailyGoal) { _ in
            // Reenvia progresso e ingestão quando a meta muda
            let goal = max(1, goalStore.dailyGoal)
            let progress = min(1, Double(intakeMl) / Double(goal))
            ConnectivityService.shared.send(goal: goal)
            ConnectivityService.shared.sendProgress(percentage: progress)
            ConnectivityService.shared.sendIntake(ml: Double(intakeMl))
        }
        .onAppear {
            // Ativa o serviço e envia estado inicial
            _ = ConnectivityService.shared
            let goal = max(1, goalStore.dailyGoal)
            let progress = min(1, Double(intakeMl) / Double(goal))
            ConnectivityService.shared.send(goal: goal)
            ConnectivityService.shared.sendProgress(percentage: progress)
            ConnectivityService.shared.sendIntake(ml: Double(intakeMl))
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveProgressUpdate)) { note in
            if let p = note.object as? Double, p >= 0, p <= 1 {
                let goal = max(1, goalStore.dailyGoal)
                let computed = Int((p * Double(goal)).rounded())
                if computed != intakeMl {
                    intakeMl = computed
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveIntakeUpdate)) { note in
            if let ml = note.object as? Double, ml >= 0 {
                let intML = Int(ml.rounded())
                if intML != intakeMl {
                    intakeMl = intML
                }
            }
        }
    }
}

#if DEBUG
private func makePreviewStore(goal: Int = 2000) -> GoalStore {
    let store = GoalStore()
    store.dailyGoal = goal
    return store
}
#endif

#Preview("Light") {
    ContentView()
        .environmentObject(makePreviewStore(goal: 2000))
}

#Preview("Dark") {
    ContentView()
        .environmentObject(makePreviewStore(goal: 2500))
        .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    ContentView()
        .environmentObject(makePreviewStore(goal: 2000))
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

