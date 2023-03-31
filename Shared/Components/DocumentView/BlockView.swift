//
//  BlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/23/23.
//

import SwiftUI

struct BlockView: View {
    let blocks: [Block]
    let onEnter: (() -> Void)
    
    @State private var value = ""
    @State private var nTopSpacers = 0
    @FocusState var isFocused: Bool
    @State private var postContentEmptiesSelectedStatus = [
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
    ]
    
    private let PROMPT_ID = UUID()

    #if os(macOS)
    private func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!) {
            if value == "" && nTopSpacers > 0 {
                nTopSpacers -= 1
            }
        }
    }
    #endif
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(blocks, id: \.id) { block in
                switch BlockType(rawValue: block.type.rawValue) {
                case .body:
                    BodyView(text: block.content) { newValue in
                        print("Update block: \(block.id) with newValue: \(newValue)")
                    }
                case .heading1:
                    HeadingView(size: .heading1, text: block.content) { newValue in
                        print("Update block: \(block.id) with newValue: \(newValue)")
                    }
                case .heading2:
                    HeadingView(size: .heading2, text: block.content) { newValue in
                        print("Update block: \(block.id) with newValue: \(newValue)")
                    }
                case .heading3:
                    HeadingView(size: .heading3, text: block.content) { newValue in
                        print("Update block: \(block.id) with newValue: \(newValue)")
                    }
                case .heading4:
                    HeadingView(size: .heading4, text: block.content) { newValue in
                        print("Update block: \(block.id) with newValue: \(newValue)")
                    }
                case .empty:
                    EmptyBlockView()
                case .bullet:
                    BulletView(text: block.content)
                case .prompt:
                    PromptField(placeholder: "Press '/' for commands...", text: $value)
                        .font(.title3)
                        .foregroundColor(ColorPalette.primaryText)
                        .onSubmit {
                            if value == "" {
                                print("on submit")
                                onEnter()
                            }
                        }
                        .onAppear {
                            #if os(macOS)
                            NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                                self.keyDown(with: $0)
                                return $0
                            }
                            #endif
                        }
                case .none:
                    EmptyView()
                }
                BlockSpacer()
            }.fixedSize(horizontal: false, vertical: true)
//            ForEach(0..<postContentEmptiesSelectedStatus.count, id: \.self) { index in
//                let status = postContentEmptiesSelectedStatus[index]
//
//                if status == true {
//                    PromptField(placeholder: "Press '/' for commands...", text: $value)
//                           .font(.title3)
//                           .focused($isFocused)
//                           .foregroundColor(ColorPalette.primaryText)
//                           .onSubmit {
//                               if value == "" {
//                                   print("on submit")
//                                   onEnter()
//                               }
//                           }
//                           .onAppear {
//                               #if os(macOS)
//                               NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
//                                   self.keyDown(with: $0)
//                                   return $0
//                               }
//                               #endif
//                           }
//                } else {
//                    EmptyBlockView()
//                        .onTapGesture {
//                            for localIndex in 0..<postContentEmptiesSelectedStatus.count {
//                                postContentEmptiesSelectedStatus[localIndex] = false
//                            }
//
//                            postContentEmptiesSelectedStatus[index] = true
//                            isFocused = true
//                        }
//                }
//
//            }
//            Group {
//                BulletView(text: "Bullet point number one")
//                BulletView(text: "Bullet point number two")
//                BulletView(text: "Bullet point number three")
//                BulletView(text: "Bullet point number four")
//            }
        }.submitScope()
    }
}
