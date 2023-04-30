//
//  PromptField.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/26/23.
//

import SwiftUI

//#if os(macOS)
fileprivate let bodyFontSize: CGFloat = 18.0

struct PromptField: View {
    let placeholder: String
    @Binding var text: String
    let onSubmit: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(.system(size: bodyFontSize))
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
            .onSubmit(onSubmit)
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
                    isFocused = true
                }
            }
    }
}

//#else
//
//class GNTextField: UITextField {
//    let onSubmit: () -> Void
//    
//    init(onSubmit: @escaping () -> Void) {
//        self.onSubmit = onSubmit
//        super.init(frame: .zero)
//        self.delegate = self
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func deleteBackward() {
//        print("Delete")
//        super.deleteBackward()
//    }
//}
//
//extension GNTextField: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.onSubmit()
//        return true
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        
//    }
//}
//
//struct PromptField: UIViewRepresentable {
//    let placeholder: String
//    @Binding var text: String
//    let onSubmit: () -> Void
//    
//    init(placeholder: String, text: Binding<String>, onSubmit: @escaping () -> Void) {
//        self.placeholder = placeholder
//        self._text = text
//        self.onSubmit = onSubmit
//    }
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        uiView.text = text
//    }
//    
//    func makeUIView(context: Context) -> some UITextField {
//        let textField = GNTextField(onSubmit: onSubmit)
//        textField.placeholder = placeholder
//        textField.text = text
//        return textField
//    }
//}
//
//#endif
