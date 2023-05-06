////
////  BodyView.swift
////  Graphnote
////
////  Created by Hayden Pennington on 3/12/23.
////
//
//import SwiftUI
//
//fileprivate let bodyFontSize: CGFloat = 18.0
//
//struct BodyView: View {
//    let id: UUID
//    let text: String
//    let editable: Bool
//    @Binding var focused: UUID?
//    let onPromptEnter: ((UUID) -> Void)?
//    let textDidChange: (_ text: String) -> Void
//    let focusChanged: (_ isFocused: Bool) -> Void
//
//    @State private var content: String = ""
//    @FocusState private var isFocused: Bool
//
//    init(id: UUID, text: String, editable: Bool = true, focused: Binding<UUID?>, onPromptEnter: ((UUID) -> Void)? = nil, textDidChange: @escaping (_: String) -> Void, focusChanged: @escaping (Bool) -> Void) {
//        self.id = id
//        self.text = text
//        self.editable = editable
//        self._focused = focused
//        self.onPromptEnter = onPromptEnter
//        self.textDidChange = textDidChange
//        self.focusChanged = focusChanged
//        self.content = text
//    }
//
//    var body: some View {
//        Group {
//            if editable {
//                PromptField(type: .body, placeholder: "Press '/'", id: id, text: $content, focused: $focused) {
//                    self.onPromptEnter?(self.id)
//                }
//                .id(id)
//                .onChange(of: content) { newValue in
//                    textDidChange(newValue)
//
//                    if newValue.isEmpty {
//                        focused = id
//                    }
//                }
//            } else {
//                Text(content)
//                    .focused($isFocused)
//                    .defaultFocus($isFocused, true)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(Spacing.spacing2.rawValue)
//                    .font(.system(size: bodyFontSize))
//            }
//        }
//        .onAppear {
//            content = text
//        }
//
//    }
//}
//
//struct BodyView_Previews: PreviewProvider {
//    static var previews: some View {
//        BodyView(id: UUID(), text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", focused: .constant(nil)) { _ in
//
//        } focusChanged: { isFocused in
//
//        }
//    }
//}
