import MajorSystemKit

extension MajorEntry: @retroactive Identifiable {
    public var id: String {
        "\(self.majorCode)_\(self.word)"
    }
}
