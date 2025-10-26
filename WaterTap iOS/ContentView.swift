
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
