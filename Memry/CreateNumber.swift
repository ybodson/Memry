import SwiftUI
import SwiftData
import MajorSystemKit

extension MajorEntry: @retroactive Identifiable {
    public var id: String {
        "\(self.majorCode)_\(self.word)"
    }
}

private struct Breadcrumb: Identifiable {
    let id: String
    let word: String
    let code: String

    init(word: String, code: String) {
        self.word = word
        self.code = code
        self.id = "\(code)_\(word)"
    }
}

struct CreateNumber: View {
    @State private var entriesByCode: [String: [MajorEntry]] = [:]
    @State private var textInput: String = ""
    @State private var breadcrumbs: [Breadcrumb] = []
    @State private var isScrollGestureActive = false

    private var matchingEntryGroups: [(code: String, entries: [MajorEntry])] {
        var groups: [(code: String, entries: [MajorEntry])] = []
        var currentCode = textInput

        while currentCode.isEmpty == false {
            if let entries = entriesByCode[currentCode], entries.isEmpty == false {
                groups.append((code: currentCode, entries: entries))
            }

            currentCode.removeLast()
        }

        return groups
    }

    var body: some View {
        NavigationStack {
            if entriesByCode.isEmpty {
                ProgressView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if breadcrumbs.isEmpty == false {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Breadcrumbs")
                                    .font(.headline)

                                TagFlowLayout(spacing: 8) {
                                    ForEach(Array(breadcrumbs.enumerated()), id: \.element.id) { index, breadcrumb in
                                        VStack(spacing: 4) {
                                            HStack(alignment: .top, spacing: 6) {
                                                ZStack(alignment: .topTrailing) {
                                                    Text(breadcrumb.word)
                                                        .font(.subheadline)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background {
                                                            Capsule()
                                                                .fill(Color.accentColor.opacity(0.14))
                                                        }
                                                        .overlay {
                                                            Capsule()
                                                                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                                                        }

                                                    if index == breadcrumbs.count - 1 {
                                                        Button(action: removeLastBreadcrumb) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .font(.body)
                                                                .foregroundStyle(.secondary)
                                                                .background(Color(.systemBackground), in: Circle())
                                                        }
                                                        .buttonStyle(.plain)
                                                        .offset(x: 6, y: -6)
                                                    }
                                                }

                                                if index < breadcrumbs.count - 1 {
                                                    Image(systemName: "arrow.right")
                                                        .font(.caption.weight(.semibold))
                                                        .foregroundStyle(.secondary)
                                                }
                                            }

                                            Text(breadcrumb.code)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Enter number")
                                .font(.headline)
                        TextField("Number", text: self.$textInput)
                            .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        if matchingEntryGroups.isEmpty == false {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(matchingEntryGroups, id: \.code) { group in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(group.code)
                                            .font(.headline)

                                        TagFlowLayout(spacing: 8) {
                                            ForEach(group.entries) { entry in
                                                Button {
                                                    guard isScrollGestureActive == false else {
                                                        return
                                                    }

                                                    select(entry.word, for: group.code)
                                                } label: {
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
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { _ in
                            isScrollGestureActive = true
                        }
                        .onEnded { _ in
                            Task {
                                try? await Task.sleep(for: .milliseconds(150))
                                isScrollGestureActive = false
                            }
                        }
                )
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

    private func select(_ word: String, for code: String) {
        guard textInput.hasPrefix(code) else {
            return
        }

        breadcrumbs.append(Breadcrumb(word: word, code: code))
        textInput.removeFirst(code.count)
    }

    private func removeLastBreadcrumb() {
        guard let breadcrumb = breadcrumbs.popLast() else {
            return
        }
        textInput = breadcrumb.code + textInput
    }
}
