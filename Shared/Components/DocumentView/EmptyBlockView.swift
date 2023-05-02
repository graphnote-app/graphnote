//
//  EmptyBlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/11/23.
//

import SwiftUI
//
//struct EmptyBlockView: View {
//    @Environment(\.colorScheme) var colorScheme
//    let id: UUID
//    let focused: UUID?
//    let action: () -> Void
//    
//    @State private var content = ""
//    
//    var body: some View {
//        if focused == id {
//            PromptField(placeholder: "Press '/'", id: id, text: $content, focused: $focused) {
//                //                self.onPromptEnter?(self.id)
//                //                    promptText = ""
//            }
////            .focused($focusedField, equals: .prompt)
////            .onAppear {
////                DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
////                    focusedField = .prompt
////                }
////            }
//        } else {
//            Rectangle()
//                .foregroundColor(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
//                .frame(height: Spacing.spacing7.rawValue)
//                .contentShape(Rectangle())
//                .onTapGesture(perform: action)
//        }
//    }
//}
