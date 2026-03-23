import SwiftUI

struct BreadcrumbChipView: View {
    let breadcrumb: Breadcrumb
    let showsArrow: Bool
    let showsDeleteButton: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top, spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Text(breadcrumb.word)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(Color.accentColor.opacity(0.14))
                        }
                        .overlay {
                            Capsule()
                                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                        }

                    if showsDeleteButton {
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .background(Color(.systemBackground), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .offset(x: 6, y: -6)
                    }
                }

                if showsArrow {
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(breadcrumb.code)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
