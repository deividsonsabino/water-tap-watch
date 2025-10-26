//
//  ContentView.swift
//  WaterTap Watch App
//
//  Created by Deividson Sabino on 25/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var waterDrankToday: Double = 0
    @AppStorage("dailyGoalString") private var dailyGoalString: String = "2000"
    @State private var customAmountString: String = ""
    @State private var animatedWater: Double = 0
    @State private var showingGoalEditor: Bool = false

    private var dailyGoal: Double {
        Double(dailyGoalString) ?? 2000
    }

    private var customAmount: Double {
        Double(customAmountString) ?? 200
    }

    var body: some View {
        ScrollView {
            // Today's Water Intake
            HStack {
                VStack(spacing: 4) {
                    WaterRingView(current: waterDrankToday, goal: dailyGoal, animatedProgress: animatedWater)
                }

                Spacer()

                Text("Daily Goal:\n\(String(format: "%.0f", dailyGoal)) ml")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.8)

                GoalControlButton { showingGoalEditor = true }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animatedWater = waterDrankToday
                }
            }
            .onChange(of: waterDrankToday) {
                withAnimation(.easeOut(duration: 0.6)) {
                    animatedWater = waterDrankToday
                }
            }

            QuickActionsCard(
                add200: { addWater(amount: 200) },
                add400: { addWater(amount: 400) },
                add600: { addWater(amount: 600) },
                minus50: { setWater(to: waterDrankToday - 50) },
                plus50: { setWater(to: waterDrankToday + 50) },
                reset: { setWater(to: 0) }
            )
            .safeAreaInset(edge: .bottom) {
                Spacer(minLength: 0)
            }
        }
        .sheet(isPresented: $showingGoalEditor) {
            GoalEditorSheet(isPresented: $showingGoalEditor, dailyGoal: dailyGoal, updateDailyGoal: updateDailyGoal)
        }
    }

    private func addWater(amount: Double) {
        let newTotal = waterDrankToday + amount
        waterDrankToday = min(newTotal, dailyGoal)
        if waterDrankToday < 0 {
            waterDrankToday = 0
        }
    }
    
    private func setWater(to value: Double) {
        let clamped = min(max(value, 0), dailyGoal)
        withAnimation(.easeOut(duration: 0.6)) {
            waterDrankToday = clamped
            animatedWater = clamped
        }
    }

    private func updateDailyGoal(to newGoal: Double) {
        let clampedGoal = max(newGoal, 200)
        dailyGoalString = String(Int(clampedGoal))
        // Ensure current totals respect the new goal
        if waterDrankToday > clampedGoal {
            setWater(to: clampedGoal)
        } else {
            // keep animation in sync
            withAnimation(.easeOut(duration: 0.6)) {
                animatedWater = waterDrankToday
            }
        }
    }
}

#Preview {
    ContentView()
}
