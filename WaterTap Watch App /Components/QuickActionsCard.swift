import SwiftUI

struct QuickActionsCard: View {
    let add200: () -> Void
    let add400: () -> Void
    let add600: () -> Void
    let minus50: () -> Void
    let plus50: () -> Void
    let reset: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Button(action: add200) {
                    Text("200ml")
                        .font(.caption2)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(width: 40, height: 18)
                }

                Button(action: add400) {
                    Text("400ml")
                        .font(.caption2)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(width: 40, height: 18)
                }

                Button(action: add600) {
                    Text("600ml")
                        .font(.caption2)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(width: 40, height: 18)
                }
            }

            HStack(spacing: 12) {
                Button(action: minus50) {
                    Text("−50")
                        .font(.caption2)
                        .frame(width: 30, height: 24)
                }
                .buttonStyle(.plain)

                Button(action: plus50) {
                    Text("+50")
                        .font(.caption2)
                        .frame(width: 30, height: 24)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 6)

                Button(action: reset) {
                    Text("Clear")
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
        )
        .padding(2)
    }
}

#Preview {
    QuickActionsCard(
        add200: {}, add400: {}, add600: {},
        minus50: {}, plus50: {}, reset: {}
    )
}
