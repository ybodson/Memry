import SwiftUI
import SwiftData
import MajorSystemKit

extension MajorEntry: @retroactive Identifiable {
    public var id: String {
        "\(self.majorCode)_\(self.word)"
    }
}

struct ContentView: View {
    @State private var entriesByCode: [String: [MajorEntry]] = [:]
    @State private var textInput: String = ""

    var body: some View {
        NavigationStack {
            if entriesByCode.isEmpty {
                ProgressView()
            } else {
                List {
                    Section("Enter number") {
                        TextField("Number", text: self.$textInput)
                            .keyboardType(.numberPad)
                    }
                    if textInput.isEmpty == false {
                        ForEach(entriesByCode[textInput] ?? []) { entry in
                            Text(entry.word)
                        }
                    }
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

#Preview {
    ContentView()
}
