import Foundation
import MajorSystemKit

struct BundledMajorIndexRepository: MajorIndexRepository {
    func loadEntriesByCode() throws -> [String: [MnemonicEntry]] {
        try MajorIndexLoader.loadBundledIndex().entriesByCode.mapValues { entries in
            entries.map { entry in
                MnemonicEntry(code: entry.majorCode, word: entry.word)
            }
        }
    }
}
