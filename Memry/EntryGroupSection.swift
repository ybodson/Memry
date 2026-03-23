import SwiftUI

struct EntryGroupSection: View {
    let group: MatchingEntryGroup
    let isTapEnabled: Bool
    let onSelectEntry: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.code)
                .font(.headline)

            TagFlowLayout(spacing: 8) {
                ForEach(Array(group.entries.enumerated()), id: \.element.id) { index, entry in
                    EntryChipView(entry: entry, isTapEnabled: isTapEnabled) {
                        onSelectEntry(index)
                    }
                }
            }
        }
    }
}
