import MajorSystemKit

protocol MajorIndexProviding {
    func loadEntriesByCode() throws -> [String: [MajorEntry]]
}
