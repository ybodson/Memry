import SwiftUI

struct TagFlowLayoutCache {
    var sizes: [CGSize] = []
    var lastWidth: CGFloat?
    var rows: [TagFlowLayoutRow] = []
}
