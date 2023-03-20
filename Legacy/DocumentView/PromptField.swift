//
//  PromptField.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/26/23.
//

import SwiftUI

#if os(macOS)

struct PromptField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
    }
}

#else

class GNTextField: UITextField {
    init() {
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
        print("Return")
        return true
    }
}

struct PromptField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UITextField {
        let textField = GNTextField()
        textField.placeholder = placeholder
        return textField
    }
}

#endif
