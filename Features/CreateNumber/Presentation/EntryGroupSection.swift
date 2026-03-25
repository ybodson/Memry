import SwiftUI

struct EntryGroupSection: View {
    let group: MatchingEntryGroup
    let onSelectEntry: (MnemonicEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.code)
                .font(.headline)

            TagFlowLayout(spacing: 8) {
                ForEach(group.entries) { entry in
                    EntryChipView(entry: entry) {
                        onSelectEntry(entry)
                    }
                }
            }
        }
    }
}
