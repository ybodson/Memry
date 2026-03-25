import SwiftUI

struct CreateNumber: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreateNumberViewModel
    private let topScrollID = "create-number-top"

    init(viewModel: CreateNumberViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        return NavigationStack {
            content(textInput: $bindableViewModel.textInput)
                .navigationTitle("New Number")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            viewModel.save()
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(!viewModel.canSave)
                    }
                }
        }
        .task {
            await viewModel.loadEntriesIfNeeded()
        }
    }

    @ViewBuilder
    private func content(textInput: Binding<String>) -> some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView {
                Label("Unable to Load Numbers", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Retry") {
                    Task {
                        await viewModel.retryLoading()
                    }
                }
            }
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Color.clear
                            .frame(height: 0)
                            .id(topScrollID)

                        if viewModel.breadcrumbs.isEmpty == false {
                            BreadcrumbsSection(
                                breadcrumbs: viewModel.breadcrumbs,
                                onDeleteLast: viewModel.removeLastBreadcrumb
                            )
                        }

                        NumberInputSection(textInput: textInput)

                        if viewModel.matchingEntryGroups.isEmpty == false {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(viewModel.matchingEntryGroups) { group in
                                    EntryGroupSection(group: group) { entry in
                                        viewModel.select(entry, in: group)
                                        scrollToTop(using: proxy)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.immediately)
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    private func scrollToTop(using proxy: ScrollViewProxy) {
        var transaction = Transaction()
        transaction.animation = nil

        withTransaction(transaction) {
            proxy.scrollTo(topScrollID, anchor: .top)
        }
    }
}
