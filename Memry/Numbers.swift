import SwiftUI

struct Numbers: View {
    @State private var isShowingCreateNumber = false

    var body: some View {
        NavigationStack {
            List {
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
            CreateNumber()
        }
    }
}
