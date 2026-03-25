import SwiftUI

struct Numbers: View {
    @State private var viewModel: NumbersViewModel
    @State private var isShowingCreateNumber = false

    init(viewModel: NumbersViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.compositions, id: \.self) { composition in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(composition.number)
                            .font(.headline)
                            .monospaced()
                        Text(composition.phrase)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
