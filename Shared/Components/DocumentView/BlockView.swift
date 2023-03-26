//
//  BlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/23/23.
//

import SwiftUI

struct BlockView: View {
    let blocks: [BlockEntity]
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
            
            ForEach(blocks, id: \.self) { block in
                BodyView(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
            }
            BlockSpacer()
//            HeadingView(size: .heading4, text: "Bullets")
//            Group {
//                BulletView(text: "Bullet point number one")
//                BulletView(text: "Bullet point number two")
//                BulletView(text: "Bullet point number three")
//                BulletView(text: "Bullet point number four")
//            }
//            BlockSpacer()
            PromptField(placeholder: "Press '/' for commands...", text: $value)
                .frame(height: Spacing.spacing7.rawValue)
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
