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
//            ForEach(blocks, id: \.self) { block in
//                switch BlockType(rawValue: block.type) {
//                case .body:
//                    BodyView(text: block.content)
//                case .heading:
//                    HeadingView(size: .heading1, text: block.content)
//                case .empty:
//                    EmptyBlockView()
//                case .bullet:
//                    BulletView(text: block.content)
//                case .none:
//                    EmptyView()
//                }
//            }
//            HeadingView(size: .heading2, text: "Technical Specification")
//            BlockSpacer()
            
            ForEach(blocks, id: \.id) { block in
                BodyView(text: block.content)
                BlockSpacer()
            }
//            HeadingView(size: .heading4, text: "Bullets")
//            Group {
//                BulletView(text: "Bullet point number one")
//                BulletView(text: "Bullet point number two")
//                BulletView(text: "Bullet point number three")
//                BulletView(text: "Bullet point number four")
//            }
//            BlockSpacer()
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
        }.submitScope()
    }
}
