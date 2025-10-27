import SwiftUI

struct LegacyWaterRingView: View {
    let current: Double
    let goal: Double
    let animatedProgress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 7)
                .frame(width: 60, height: 60)
            Circle()
                .trim(from: 0, to: CGFloat(min(animatedProgress / max(goal, 1), 1.0)))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 60, height: 60)
            Text("\(String(format: "%.0f", current))\nml")
                .multilineTextAlignment(.center)
                .font(.headline)
                .bold()
                .minimumScaleFactor(0.5)
                .lineLimit(2)
        }
    }
}

#Preview {
    LegacyWaterRingView(current: 750, goal: 2000, animatedProgress: 750)
}
