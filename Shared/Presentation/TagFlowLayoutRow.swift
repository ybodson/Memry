import SwiftUI

struct TagFlowLayoutRow {
    var elements: [TagFlowLayoutElement] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
    var yOffset: CGFloat = 0

    mutating func add(index: Int, size: CGSize, spacing: CGFloat) {
        let xOffset = elements.isEmpty ? 0 : width + spacing
        elements.append(TagFlowLayoutElement(index: index, size: size, xOffset: xOffset))
        width = xOffset + size.width
        height = max(height, size.height)
    }
}
