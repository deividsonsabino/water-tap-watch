import SwiftUI

public struct WaterRingView: View {
    public var progress: Double            // 0.0 ... 1.0
    public var lineWidth: CGFloat = 16
    public var showsLabel: Bool = true

    public init(progress: Double, lineWidth: CGFloat = 16, showsLabel: Bool = true) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.showsLabel = showsLabel
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundStyle(.quaternary)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.blue, .cyan, .teal, .blue]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)

            if showsLabel {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hydration progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

#Preview {
    VStack(spacing: 24) {
        WaterRingView(progress: 0.3)
            .frame(width: 160, height: 160)
        WaterRingView(progress: 0.75, lineWidth: 20)
            .frame(width: 160, height: 160)
    }
    .padding()
}
