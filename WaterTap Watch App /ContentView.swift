import SwiftUI
import WatchKit

struct ContentView: View {
    @EnvironmentObject var goalStore: GoalStore
    @State private var waterDrankToday: Double = 0
    @State private var showingGoalEditor = false

    private let appGroupSuiteName = "group.com.deivao.watertap"
    private let intakeDefaultsKey = "waterDrankToday"

    private func loadPersistedIntake() {
        let storage = UserDefaults(suiteName: appGroupSuiteName) ?? .standard
        if let stored = storage.object(forKey: intakeDefaultsKey) as? Double, stored >= 0 {
            waterDrankToday = stored
        }
    }

    private func savePersistedIntake(_ value: Double) {
        let storage = UserDefaults(suiteName: appGroupSuiteName) ?? .standard
        storage.set(value, forKey: intakeDefaultsKey)
    }

    private var dailyGoal: Double { Double(goalStore.dailyGoal) }
    private var progress: Double { min(1, dailyGoal > 0 ? waterDrankToday / dailyGoal : 0) }

    var body: some View {
        GeometryReader { proxy in
            // Adaptive metrics based on available width (works across watch sizes)
            let w = proxy.size.width
            let ringSize = max(48, min(88, w * 0.36))
            let cardPadding = w < 140 ? 6.0 : 8.0
            let borderWidth = w < 140 ? 0.6 : 1.0
            let headerFont: Font = w < 140 ? .caption2 : .caption
            let ringLineWidth: CGFloat = w < 140 ? 8 : 10

            ScrollView {
                VStack(spacing: 8) {
                    // Card container with adaptive border
                    HStack(spacing: 8) {
                        WaterRingView(
                            progress: progress,
                            lineWidth: ringLineWidth
                        )
                        .frame(width: ringSize, height: ringSize)

                        Spacer(minLength: 4)

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Daily Goal:")
                                .font(headerFont)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text("\(Int(dailyGoal)) ml")
                                .font(headerFont)
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }

                        GoalControlButton { showingGoalEditor = true }
                    }
                    .padding(cardPadding)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(.separator.opacity(0.25), lineWidth: borderWidth)
                    }

                    // Quick actions (mantidos)
                    QuickActionsCard(
                        add200: { addWater(amount: 200) },
                        add400: { addWater(amount: 400) },
                        add600: { addWater(amount: 600) },
                        minus50: { setWater(to: waterDrankToday - 50) },
                        plus50: { setWater(to: waterDrankToday + 50) },
                        reset: { setWater(to: 0) }
                    )
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
            }
        }
        .sheet(isPresented: $showingGoalEditor) {
            GoalEditorSheet(
                isPresented: $showingGoalEditor,
                dailyGoal: dailyGoal,
                updateDailyGoal: updateDailyGoal
            )
        }
        .onAppear {
            // Carrega o último valor salvo de ingestão
            loadPersistedIntake()
        }
        .onChange(of: waterDrankToday) { newValue in
            let goal = max(1, goalStore.dailyGoal)
            let progress = min(1, newValue / Double(goal))
            ConnectivityService.shared.sendProgress(percentage: progress)
            ConnectivityService.shared.sendIntake(ml: newValue)
            savePersistedIntake(newValue)
        }
        .onChange(of: goalStore.dailyGoal) { _ in
            let goal = max(1, goalStore.dailyGoal)
            let progress = min(1, waterDrankToday / Double(goal))
            ConnectivityService.shared.send(goal: goal)
            ConnectivityService.shared.sendProgress(percentage: progress)
            ConnectivityService.shared.sendIntake(ml: waterDrankToday)
        }
        .onAppear {
            _ = ConnectivityService.shared
            let goal = max(1, goalStore.dailyGoal)
            let progress = min(1, waterDrankToday / Double(goal))
            ConnectivityService.shared.send(goal: goal)
            ConnectivityService.shared.sendProgress(percentage: progress)
            ConnectivityService.shared.sendIntake(ml: waterDrankToday)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveProgressUpdate)) { note in
            if let p = note.object as? Double, p >= 0, p <= 1 {
                let goal = max(1, goalStore.dailyGoal)
                let computed = p * Double(goal)
                if abs(computed - waterDrankToday) > 0.5 {
                    withAnimation { waterDrankToday = computed }
                    savePersistedIntake(computed)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveIntakeUpdate)) { note in
            if let ml = note.object as? Double, ml >= 0 {
                if abs(ml - waterDrankToday) > 0.5 {
                    withAnimation { waterDrankToday = ml }
                    savePersistedIntake(ml)
                }
            }
        }
    }

    private func addWater(amount: Double) {
        let newTotal = min(waterDrankToday + amount, dailyGoal)
        setWater(to: newTotal)
    }

    private func setWater(to value: Double) {
        let clamped = min(max(value, 0), dailyGoal)
        withAnimation(.easeOut(duration: 0.6)) {
            waterDrankToday = clamped
        }
        WKInterfaceDevice.current().play(.click)
    }

    private func updateDailyGoal(to newGoal: Double) {
        let clampedGoal = max(newGoal, 200)
        goalStore.dailyGoal = Int(clampedGoal)

        // Reajuste intake se passou da nova meta
        if waterDrankToday > clampedGoal {
            setWater(to: clampedGoal)
        }
    }
}
