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
    let block: Block
    @Binding var focused: FocusedPrompt
    @Binding var promptMenuOpen: Bool
    let onSubmit: (_ id: UUID, _ text: String) -> Void
    let onBackspaceRemove: () -> Void
    
    @FocusState private var isFocused: Bool
    
    private let placeholder = "Press '/'"
    @State private var text = ""
    
    @State private var isKeyDown = false
    @State private var numMonitor: Any? = nil

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
    
    var body: some View {
        TextField("", text: $text, prompt: Text(text.isEmpty ? placeholder : ""), axis: .vertical)
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
            .onAppear {
                if id == block.id {
                    text = block.content
                }
                
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
            .onChange(of: block.content, perform: { newValue in
                text = newValue
            })
            .onChange(of: focused.uuid) { newValue in
                isFocused = newValue == id
            }
            .onChange(of: isFocused) { newValue in
                if newValue == true {
                    
                    focused = FocusedPrompt(uuid: id, text: block.content)
                    
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
