import SwiftUI

struct GoalControlButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .font(.body)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GoalControlButton(action: {})
}
