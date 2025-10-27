
import SwiftUI

#if os(watchOS)
let defaultLabelFont: Font = .system(size: 18, weight: .semibold, design: .rounded)
#else
let defaultLabelFont: Font = .system(size: 28, weight: .semibold, design: .rounded)
#endif

public struct WaterRingView: View {
    // MARK: - Public configuration
    public var progress: Double            // 0.0 ... 1.0
    public var lineWidth: CGFloat
    public var colors: [Color]
    public var backgroundColor: Color
    public var showsLabel: Bool
    public var labelFont: Font
    public var labelFormat: LabelFormat
    public var startAngle: Double          // degrees, default -90 so it starts at top
    public var animationDuration: Double

    public enum LabelFormat: Equatable {
        case percent                       // shows "65%"
        case custom(String)                // shows provided string (e.g., "600 ml")
    }

    // MARK: - Init
    public init(
        progress: Double,
        lineWidth: CGFloat = 16,
        showsLabel: Bool = true,
        colors: [Color] = [.blue, .cyan, .teal, .blue],
        backgroundColor: Color = .secondary.opacity(0.2),
        labelFont: Font? = nil,
        labelFormat: LabelFormat = .percent,
        startAngle: Double = -90,
        animationDuration: Double = 0.6
    ) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.colors = colors
        self.backgroundColor = backgroundColor
        self.showsLabel = showsLabel

        #if os(watchOS)
        self.labelFont = labelFont ?? .system(size: 18, weight: .semibold, design: .rounded)
        #else
        self.labelFont = labelFont ?? .system(size: 28, weight: .semibold, design: .rounded)
        #endif

        self.labelFormat = labelFormat
        self.startAngle = startAngle
        self.animationDuration = animationDuration
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundStyle(backgroundColor)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: colors),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(startAngle))
                .animation(.easeInOut(duration: animationDuration), value: progress)

            if showsLabel {
                labelView
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hydration progress")
        .accessibilityValue(accessibilityValueText)
    }

    // MARK: - Private helpers
    private var labelView: some View {
        switch labelFormat {
        case .percent:
            return Text("\(Int(progress * 100))%")
                .font(labelFont)
                .monospacedDigit()
                .foregroundStyle(.primary)
                .eraseToAnyView()
        case .custom(let text):
            return Text(text)
                .font(labelFont)
                .foregroundStyle(.primary)
                .eraseToAnyView()
        }
    }

    private var accessibilityValueText: String {
        switch labelFormat {
        case .percent:
            return "\(Int(progress * 100)) percent"
        case .custom(let text):
            return text
        }
    }
}

// Small helper for type erasure of views from switch
private extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}

#Preview {
    VStack(spacing: 24) {
        // Default
        WaterRingView(progress: 0.35)
            .frame(width: 140, height: 140)

        // Thicker line + custom label text (e.g., device-specific)
        WaterRingView(progress: 0.6,
                      lineWidth: 20,
                      labelFormat: .custom("1200 ml"))
            .frame(width: 160, height: 160)

        // Custom colors + faster animation
        WaterRingView(progress: 0.8,
                      colors: [.mint, .green, .blue, .mint],
                      animationDuration: 0.3)
            .frame(width: 160, height: 160)
    }
    .padding()
}
