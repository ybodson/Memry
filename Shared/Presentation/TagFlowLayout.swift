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
        for row in rows(for: bounds.width, cache: &cache) {
            place(row, in: bounds, subviews: subviews)
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
        positionedRows(from: buildRows(in: maxWidth, sizes: sizes))
    }

    private func place(_ row: TagFlowLayoutRow, in bounds: CGRect, subviews: Subviews) {
        for element in row.elements {
            place(element, in: row, bounds: bounds, subviews: subviews)
        }
    }

    private func place(_ element: TagFlowLayoutElement, in row: TagFlowLayoutRow, bounds: CGRect, subviews: Subviews) {
        subviews[element.index].place(at: point(for: element, in: row, bounds: bounds), proposal: ProposedViewSize(element.size))
    }

    private func point(for element: TagFlowLayoutElement, in row: TagFlowLayoutRow, bounds: CGRect) -> CGPoint {
        CGPoint(x: bounds.minX + element.xOffset, y: bounds.minY + row.yOffset)
    }

    private func buildRows(in maxWidth: CGFloat, sizes: [CGSize]) -> [TagFlowLayoutRow] {
        var rows: [TagFlowLayoutRow] = []
        var row = TagFlowLayoutRow()
        for (index, size) in sizes.enumerated() { append(size, at: index, to: &row, rows: &rows, maxWidth: maxWidth) }
        finish(row, into: &rows)
        return rows
    }

    private func append(_ size: CGSize, at index: Int, to row: inout TagFlowLayoutRow, rows: inout [TagFlowLayoutRow], maxWidth: CGFloat) {
        if wraps(size, in: row, maxWidth: maxWidth) { finish(row, into: &rows); row = TagFlowLayoutRow() }
        row.add(index: index, size: size, spacing: spacing)
    }

    private func wraps(_ size: CGSize, in row: TagFlowLayoutRow, maxWidth: CGFloat) -> Bool {
        row.elements.isEmpty == false && nextX(in: row) + size.width > maxWidth
    }

    private func nextX(in row: TagFlowLayoutRow) -> CGFloat {
        row.elements.isEmpty ? 0 : row.width + spacing
    }

    private func finish(_ row: TagFlowLayoutRow, into rows: inout [TagFlowLayoutRow]) {
        guard row.elements.isEmpty == false else { return }
        rows.append(row)
    }

    private func positionedRows(from rows: [TagFlowLayoutRow]) -> [TagFlowLayoutRow] {
        var yOffset: CGFloat = 0
        return rows.map { position($0, yOffset: &yOffset) }
    }

    private func position(_ row: TagFlowLayoutRow, yOffset: inout CGFloat) -> TagFlowLayoutRow {
        var row = row
        row.yOffset = yOffset
        yOffset += row.height + spacing
        return row
    }
}
