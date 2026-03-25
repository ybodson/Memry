import SwiftUI

struct Numbers: View {
    @State private var viewModel: NumbersViewModel
    @State private var isShowingCreateNumber = false

    init(viewModel: NumbersViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.compositions.isEmpty {
                    ContentUnavailableView(
                        "No Numbers Yet",
                        systemImage: "number",
                        description: Text("Tap + to memorize your first number.")
                    )
                } else {
                    List {
                        ForEach(viewModel.compositions) { composition in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(composition.number)
                                    .font(.headline)
                                    .monospaced()
                                Text(composition.phrase)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                viewModel.delete(viewModel.compositions[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Numbers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingCreateNumber = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingCreateNumber) {
            viewModel.loadCompositions()
        } content: {
            CreateNumberFeature.makeView(onSave: viewModel.save)
        }
        .onAppear {
            viewModel.loadCompositions()
        }
    }
}
