import SwiftUI

struct GoalValueText: View {
    let value: Int

    var body: some View {
        Text("\(value) ml")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .accessibilityLabel("Daily goal is \(value) milliliters")
    }
}

