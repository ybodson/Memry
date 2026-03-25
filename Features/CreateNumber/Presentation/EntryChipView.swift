import SwiftUI

struct EntryChipView: View {
    let entry: MnemonicEntry
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Text(entry.word)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(Color(.systemBackground))
                }
                .overlay {
                    Capsule()
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
