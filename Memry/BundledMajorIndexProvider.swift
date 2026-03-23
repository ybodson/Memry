import MajorSystemKit

struct BundledMajorIndexProvider: MajorIndexProviding {
    func loadEntriesByCode() throws -> [String: [MajorEntry]] {
        try MajorIndexLoader.loadBundledIndex().entriesByCode
    }
}
