import SwiftUI

struct TagFlowLayoutRow {
    var elements: [TagFlowLayoutElement] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
    var yOffset: CGFloat = 0

    mutating func finalize() {
        if elements.isEmpty {
            width = 0
            height = 0
        }
    }
}
