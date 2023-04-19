//
//  PromptField.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/26/23.
//

import SwiftUI

#if os(macOS)
fileprivate let bodyFontSize: CGFloat = 18.0

struct PromptField: View {
    let placeholder: String
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(.system(size: bodyFontSize))
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
            .onSubmit(onSubmit)
    }
}

#else

class GNTextField: UITextField {
    let onSubmit: () -> Void
    
    init(onSubmit: @escaping () -> Void) {
        self.onSubmit = onSubmit
        super.init(frame: .zero)
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        print("Delete")
        super.deleteBackward()
    }
}

extension GNTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onSubmit()
        return true
    }
}

struct GNTextFieldView: UIViewRepresentable {
    typealias UIViewType = UITextField
    
    let placeholder: String
    @Binding var text: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = text
    }
    
    func makeUIView(context: Context) ->  UIViewType {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.text = text
        return textField
    }
}

struct PromptField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    let onSubmit: () -> Void
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UITextField {
        let textField = GNTextField(onSubmit: onSubmit)
        textField.placeholder = placeholder
        return textField
    }
}

#endif
