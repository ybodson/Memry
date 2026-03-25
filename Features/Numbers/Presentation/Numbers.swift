import CoreData
import SwiftUI

struct Numbers: View {
    @Environment(\.scenePhase) private var scenePhase
    @State var viewModel: NumbersViewModel
    @State private var isShowingCreateNumber = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.showsLoadingSkeleton {
                    List {
                        ForEach(0..<3, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("0000000")
                                    .font(.headline)
                                    .monospaced()
                                Text("placeholder phrase text")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .redacted(reason: .placeholder)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("Unable to Load Numbers", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Retry") {
                            viewModel.loadCompositions()
                        }
                    }
                } else if viewModel.compositions.isEmpty {
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
        .task {
            await viewModel.startObservingCloudSync()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.loadCompositions()
            }
        }
    }
}
