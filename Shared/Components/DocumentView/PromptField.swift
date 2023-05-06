//
//  PromptField.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/26/23.
//

import SwiftUI

struct PromptFontDimensions {
    static let bodyFontSize: CGFloat = 20.0
}

enum PromptFieldNotification: String {
    case focusChanged
}

struct PromptField: View {
    let id: UUID
    let type: BlockType
    let block: Block
//    @Binding var text: String
    @Binding var focused: FocusedPrompt
    let onSubmit: () -> Void
    
    @FocusState private var isFocused: Bool
    
    private let placeholder = "Press '/'"
    @State private var text = ""
    
    var font: Font {
        switch type {
        case .body:
            return .custom("", size: PromptFontDimensions.bodyFontSize, relativeTo: .body)
        default:
            return .subheadline
        }
    }
    
    var body: some View {
        TextField("", text: $text, prompt: Text(focused.uuid == id ? placeholder : ""), axis: .vertical)
            .font(font)
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
            .padding([.top, .bottom])
            .focused($isFocused)
            .onSubmit(onSubmit)
            .onAppear {
                if focused.uuid == id {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0125) {
                        isFocused = true
                    }
                }
            }
            .onChange(of: focused.uuid) { newValue in
                if newValue == id {
                    isFocused = true
                } else {
                    isFocused = false
                }
            }
            .onChange(of: isFocused) { newValue in
                if newValue == true {
                    focused = FocusedPrompt(uuid: id, text: block.content)
                }
            }
    }
}
