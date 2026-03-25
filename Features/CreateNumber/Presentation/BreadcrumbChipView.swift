import SwiftUI

struct BreadcrumbChipView: View {
    let breadcrumb: Breadcrumb
    let showsArrow: Bool
    let showsDeleteButton: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .center, spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Text(breadcrumb.word)
                        .font(.subheadline)
                        .foregroundStyle(Color(.label))
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
                        .frame(maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Text(breadcrumb.code)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
