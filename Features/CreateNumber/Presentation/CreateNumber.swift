import SwiftUI

struct CreateNumber: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateNumberViewModel
    private let topScrollID = "create-number-top"

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        return NavigationStack {
            content(textInput: $bindableViewModel.textInput)
                .navigationTitle("New Number")
                .toolbar { toolbar }
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private func content(textInput: Binding<String>) -> some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let errorMessage = viewModel.errorMessage {
            CreateNumberErrorView(message: errorMessage) { Task { await viewModel.retry() } }
        } else {
            CreateNumberContentView(
                viewModel: viewModel,
                textInput: textInput,
                topScrollID: topScrollID,
                onScrollToTop: scrollToTop
            )
        }
    }

    private func scrollToTop(using proxy: ScrollViewProxy) {
        withTransaction(topScrollTransaction) { proxy.scrollTo(topScrollID, anchor: .top) }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { cancelButton }
        ToolbarItem(placement: .confirmationAction) { saveButton }
    }

    private var cancelButton: some View {
        Button(action: dismiss.callAsFunction) { Image(systemName: "xmark") }
    }

    private var saveButton: some View {
        Button(action: saveAndDismiss) { Image(systemName: "checkmark") }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canSave)
    }

    private var topScrollTransaction: Transaction {
        var transaction = Transaction()
        transaction.animation = nil
        return transaction
    }

    private func saveAndDismiss() {
        if viewModel.save() { dismiss() }
    }
}

private struct CreateNumberErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Unable to Load Numbers", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: onRetry)
        }
    }
}

private struct CreateNumberContentView: View {
    let viewModel: CreateNumberViewModel
    let textInput: Binding<String>
    let topScrollID: String
    let onScrollToTop: (ScrollViewProxy) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView { sections(using: proxy) }
                .scrollDismissesKeyboard(.immediately)
                .background(Color(.systemGroupedBackground))
        }
    }

    private func sections(using proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            topAnchor
            breadcrumbsSection
            NumberInputSection(textInput: textInput)
            entryGroups(using: proxy)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var topAnchor: some View {
        Color.clear.frame(height: 0).id(topScrollID)
    }

    @ViewBuilder
    private var breadcrumbsSection: some View {
        if viewModel.breadcrumbs.isEmpty == false {
            BreadcrumbsSection(breadcrumbs: viewModel.breadcrumbs, onDeleteLast: viewModel.pop)
        }
    }

    @ViewBuilder
    private func entryGroups(using proxy: ScrollViewProxy) -> some View {
        if viewModel.matchingEntryGroups.isEmpty == false {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.matchingEntryGroups) { group in
                    EntryGroupSection(group: group) { entry in
                        viewModel.select(entry, in: group)
                        onScrollToTop(proxy)
                    }
                }
            }
        }
    }
}
