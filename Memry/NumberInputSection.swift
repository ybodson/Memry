import SwiftUI

struct NumberInputSection: View {
    @Binding var textInput: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter number")
                .font(.headline)

            TextField("Number", text: $textInput)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
        }
    }
}
