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

struct PromptField: View {
    let id: UUID
    let type: BlockType
    @Binding var text: String
    @Binding var focused: FocusedPrompt
    @Binding var promptMenuOpen: Bool
    let onSubmit: (_ id: UUID, _ text: String) -> Void
    let onBackspaceRemove: () -> Void
    
    @FocusState private var isFocused: Bool
    
    private let placeholder = "Press '/'"
    
    @State private var isKeyDown = false
    @State private var numMonitor: Any? = nil
    @State private var promptSize: CGSize = .zero

    #if os(macOS)
    private func keyDown(with event: NSEvent) -> Bool {
        if event.charactersIgnoringModifiers == "\r" && event.isARepeat == true {
            return false
        }
        
        if event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!) && event.isARepeat == false {
            if self.text.isEmpty {
                self.onBackspaceRemove()
            }
       }
        
       return true
    }
    #endif
    
    var font: Font {
        switch type {
        case .body:
            return .custom("", size: PromptFontDimensions.bodyFontSize, relativeTo: .body)
        default:
            return .subheadline
        }
    }
    
    var textField: some View {
        #if os(macOS)
        return TextField("", text: $text, prompt: Text(text.isEmpty && id == focused.uuid ? placeholder : ""), axis: .vertical)
            .font(font)
            .lineSpacing(Spacing.spacing2.rawValue)
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
            .padding([.top, .bottom], Spacing.spacing2.rawValue)
            .focused($isFocused)
            .onSubmit {
                self.onSubmit(id, text)
            }
        #else
        return ZStack {
            TextField("", text: $text, prompt: Text(text.isEmpty && id == focused.uuid ? placeholder : ""), axis: .vertical)
              .font(font)
              .lineSpacing(Spacing.spacing2.rawValue)
              .disableAutocorrection(true)
              .textFieldStyle(.plain)
              .multilineTextAlignment(.leading)
              .padding([.top, .bottom], Spacing.spacing2.rawValue)
              .disabled(true)
              .opacity(0)
              .frame(height: promptSize.height)
              .background(
                  GeometryReader { proxy in
                      HStack {}
                      .onAppear {
                          promptSize = proxy.size
                      }
                  }
              )
              .border(.green)
            UITextViewRepresentable(text: $text, prompt: text.isEmpty && id == focused.uuid ? placeholder : "", size: $promptSize) {
                self.onBackspaceRemove()
            } onReturn: {
                self.onSubmit(id, text)
            }
                .focused($isFocused)
                .frame(height: promptSize.height)
                .zIndex(1)
                .border(.red)
        }
          
        #endif
    }
    
    var body: some View {
        textField
            .onAppear {
                if focused.uuid == id {
                    #if os(macOS)
                    self.numMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                        if self.isKeyDown == false {
                            self.isKeyDown = true
                            if self.keyDown(with: $0) == false {
                                self.isKeyDown = false
                                return nil
                            }
                            
                            self.isKeyDown = false
                        }
                        
                        return $0
                    }
                    #endif
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
                        if isFocused == false {
                            isFocused = true
                        }
                    }
                }
            }
            .onDisappear {
                #if os(macOS)
                if let numMonitor {
                    NSEvent.removeMonitor(numMonitor)
                    self.numMonitor = nil
                }
                #endif
            }
            .onChange(of: focused.uuid) { newValue in
                isFocused = newValue == id
            }
            .onChange(of: isFocused) { newValue in
                if newValue == true {
                    
                    focused = FocusedPrompt(uuid: id, text: text)
                    
                    if focused.uuid == id {
                        #if os(macOS)
                        if let numMonitor {
                            NSEvent.removeMonitor(numMonitor)
                            self.numMonitor = nil
                        }
                        self.numMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                        if self.isKeyDown == false {
                                self.isKeyDown = true
                                if self.keyDown(with: $0) == false {
                                    self.isKeyDown = false
                                    return nil
                                }
                                
                                self.isKeyDown = false
                            }
                            
                            return $0
                        }
                        #endif
                    }
                    
                } else {
                    #if os(macOS)
                    if let numMonitor {
                        NSEvent.removeMonitor(numMonitor)
                        self.numMonitor = nil
                    }
                    #endif
                }
            }
            .onChange(of: text) { newValue in
                if newValue == "/" {
                    withAnimation {
                        promptMenuOpen = true
                    }
                    
                } else if newValue == "" {
                    withAnimation {
                        promptMenuOpen = false
                    }
                }
            }
    }
}

#if os(iOS)

class GNTextView: UITextView, UITextViewDelegate {
    @Binding var size: CGSize
    @Binding var promptText: String
    
    let onDelete: () -> Void
    let onReturn: () -> Void
    
    init(size: Binding<CGSize>, promptText: Binding<String>, onDelete: @escaping () -> Void, onReturn: @escaping () -> Void) {
        self._size = size
        self._promptText = promptText
        self.onDelete = onDelete
        self.onReturn = onReturn
        
        super.init(frame: .zero, textContainer: nil)
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if contentSize.width > .zero && contentSize.height > .zero {
            size = contentSize
        }
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        if text.isEmpty {
            onDelete()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            // On Return! (iOS)
            onReturn()
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.promptText = textView.text
        }
    }
}

struct UITextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    let prompt: String
    @Binding var size: CGSize
    
    let onDelete: () -> Void
    let onReturn: () -> Void
    
    typealias UIViewType = GNTextView

    func makeUIView(context: Context) -> UIViewType {
        let textView = UIViewType(size: $size, promptText: $text, onDelete: onDelete, onReturn: onReturn)
        textView.text = text
        textView.font = .systemFont(ofSize: PromptFontDimensions.bodyFontSize)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.frame.size = size
        return textView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = text
        uiView.frame.size = size
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#endif
