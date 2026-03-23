import MajorSystemKit
import SwiftUI

struct EntryChipView: View {
    let entry: MajorEntry
    let isTapEnabled: Bool
    let onSelect: () -> Void

    var body: some View {
        Button {
            guard isTapEnabled else {
                return
            }

            onSelect()
        } label: {
            Text(entry.word)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(Color.secondary.opacity(0.14))
                }
                .overlay {
                    Capsule()
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
