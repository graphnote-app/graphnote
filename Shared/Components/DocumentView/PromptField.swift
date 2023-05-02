//
//  PromptField.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/26/23.
//

import SwiftUI

//#if os(macOS)
fileprivate let bodyFontSize: CGFloat = 18.0

enum PromptFieldNotification: String {
    case focusChanged
}

struct PromptField: View {
    let placeholder: String
    let id: UUID
    @Binding var text: String
    @Binding var focused: UUID?
    let onSubmit: () -> Void
    let focusChanged: (_ isFocused: Bool) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Group {
            if focused == id {
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(.system(size: bodyFontSize))
                    .disableAutocorrection(true)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.leading)
                    .onSubmit(onSubmit)
                    .focused($isFocused)
                    .onAppear {
                        if focused == id {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0125) {
                                isFocused = true
                            }
                        }
                    }
                    .onChange(of: focused) { newValue in
                        if newValue == id {
                            isFocused = true
                        } else {
                            isFocused = false
                        }
                    }

            } else {
                TextField("", text: $text, axis: .vertical)
                    .font(.system(size: bodyFontSize))
                    .disableAutocorrection(true)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.leading)
                    .focused($isFocused)
                    .onChange(of: isFocused) { newValue in
                        if newValue == true {
                            focused = id
                        }
                    }
                    .onChange(of: focused) { newValue in
                        if newValue == id {
                            isFocused = true
                        } else {
                            isFocused = false
                        }
                    }
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
