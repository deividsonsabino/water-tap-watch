import SwiftUI

// Simple wrapping flow layout for small controls
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content

    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        _FlowLayout(spacing: spacing) { content() }
    }
}

private struct _FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth { // wrap
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.minX + maxWidth { // wrap
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct GoalEditorSheet: View {
    @Binding var isPresented: Bool
    let dailyGoal: Double
    let updateDailyGoal: (Double) -> Void
    private let dailyGoalDefaultsKey = "dailyGoal"

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 8) {
                    Text("Daily Goal")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Fine adjustments
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Adjust")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        FlowLayout(spacing: 8) {
                            Button("−100 ml") {
                                let newValue = max(dailyGoal - 100, 200)
                                UserDefaults.standard.set(newValue, forKey: dailyGoalDefaultsKey)
                                updateDailyGoal(newValue)
                            }
                            .buttonStyle(.bordered)
                            Button("+100 ml") {
                                let newValue = dailyGoal + 100
                                UserDefaults.standard.set(newValue, forKey: dailyGoalDefaultsKey)
                                updateDailyGoal(newValue)
                            }
                            .buttonStyle(.bordered)
                        }
                        .font(.caption2)
                    }

                    Divider()
                        .padding(.vertical, 4)

                    // Stepper editor
                    Stepper(value: Binding(
                        get: { Int(dailyGoal) },
                        set: {
                            let newValue = Double($0)
                            UserDefaults.standard.set(newValue, forKey: dailyGoalDefaultsKey)
                            updateDailyGoal(newValue)
                        }
                    ), in: 500...6000, step: 100) {
                        Text("\(Int(dailyGoal)) ml").font(.caption)
                    }
                }
                .onAppear {
                    if let stored = UserDefaults.standard.object(forKey: dailyGoalDefaultsKey) as? Double, stored > 0 {
                        updateDailyGoal(stored)
                    }
                }
                .padding(8)
            }
        }
    }
}

#Preview {
    GoalEditorSheet(isPresented: .constant(true), dailyGoal: 2000, updateDailyGoal: { _ in })
}
