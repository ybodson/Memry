import SwiftUI
import SwiftData
import MajorSystemKit

extension MajorEntry: @retroactive Identifiable {
    public var id: String {
        "\(self.majorCode)_\(self.word)"
    }
}

struct CreateNumber: View {
    @State private var entriesByCode: [String: [MajorEntry]] = [:]
    @State private var textInput: String = ""

    var body: some View {
        NavigationStack {
            if entriesByCode.isEmpty {
                ProgressView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Enter number")
                                .font(.headline)
                        TextField("Number", text: self.$textInput)
                            .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        if textInput.isEmpty == false {
                            TagFlowLayout(spacing: 8) {
                                ForEach(entriesByCode[textInput] ?? []) { entry in
                                    Text(entry.word)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background {
                                            Capsule()
                                                .fill(Color.secondary.opacity(0.14))
                                        }
                                        .overlay {
                                            Capsule()
                                                .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("Number")
            }
        }
        .task {
            do {
                let index = try MajorIndexLoader.loadBundledIndex()
                self.entriesByCode = index.entriesByCode
            } catch {
                print(error)
            }
        }
    }
}

