import SwiftUI

struct TagFlowLayout: Layout {
    let spacing: CGFloat

    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    func makeCache(subviews: Subviews) -> TagFlowLayoutCache {
        TagFlowLayoutCache(sizes: subviews.map { $0.sizeThatFits(.unspecified) })
    }

    func updateCache(_ cache: inout TagFlowLayoutCache, subviews: Subviews) {
        cache.sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        cache.lastWidth = nil
        cache.rows = []
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout TagFlowLayoutCache
    ) -> CGSize {
        let rows = rows(for: proposal.width ?? .infinity, cache: &cache)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let height = rows.last.map { $0.yOffset + $0.height } ?? 0

        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout TagFlowLayoutCache
    ) {
        let rows = rows(for: bounds.width, cache: &cache)

        for row in rows {
            for element in row.elements {
                let point = CGPoint(
                    x: bounds.minX + element.xOffset,
                    y: bounds.minY + row.yOffset
                )
                subviews[element.index].place(
                    at: point,
                    proposal: ProposedViewSize(element.size)
                )
            }
        }
    }

    private func rows(for width: CGFloat, cache: inout TagFlowLayoutCache) -> [TagFlowLayoutRow] {
        if cache.lastWidth != width {
            cache.rows = arrangeRows(in: width, sizes: cache.sizes)
            cache.lastWidth = width
        }

        return cache.rows
    }

    private func arrangeRows(in maxWidth: CGFloat, sizes: [CGSize]) -> [TagFlowLayoutRow] {
        var rows: [TagFlowLayoutRow] = []
        var currentRow = TagFlowLayoutRow()

        for (index, size) in sizes.enumerated() {
            let proposedX = currentRow.elements.isEmpty ? 0 : currentRow.width + spacing
            if proposedX + size.width > maxWidth, currentRow.elements.isEmpty == false {
                currentRow.finalize()
                rows.append(currentRow)
                currentRow = TagFlowLayoutRow()
            }

            currentRow.elements.append(
                TagFlowLayoutElement(
                    index: index,
                    size: size,
                    xOffset: currentRow.elements.isEmpty ? 0 : currentRow.width + spacing
                )
            )
            currentRow.width = (currentRow.elements.last?.xOffset ?? 0) + size.width
            currentRow.height = max(currentRow.height, size.height)
        }

        if currentRow.elements.isEmpty == false {
            currentRow.finalize()
            rows.append(currentRow)
        }

        var yOffset: CGFloat = 0
        return rows.map { row in
            var updatedRow = row
            updatedRow.yOffset = yOffset
            yOffset += row.height + spacing
            return updatedRow
        }
    }
}
