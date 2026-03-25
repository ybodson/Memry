import Foundation

protocol MajorIndexRepository: Sendable {
    func loadEntriesByCode() throws -> [String: [MnemonicEntry]]
}
