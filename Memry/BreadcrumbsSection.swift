import SwiftUI

struct BreadcrumbsSection: View {
    let breadcrumbs: [Breadcrumb]
    let onDeleteLast: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Breadcrumbs")
                .font(.headline)

            TagFlowLayout(spacing: 8) {
                ForEach(Array(breadcrumbs.enumerated()), id: \.element.id) { index, breadcrumb in
                    BreadcrumbChipView(
                        breadcrumb: breadcrumb,
                        showsArrow: index < breadcrumbs.count - 1,
                        showsDeleteButton: index == breadcrumbs.count - 1,
                        onDelete: onDeleteLast
                    )
                }
            }
        }
    }
}
