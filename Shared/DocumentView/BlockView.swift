//
//  BlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/23/23.
//

import SwiftUI

struct BlockView: View {
    let blocks: [Block]
    
    @State private var value = ""
    @State private var nTopSpacers = 0
    @State private var enterAction: (() -> Void)? = nil

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
        VStack {
            ForEach(blocks, id: \.self) { block in
                EmptyBlockView()
            }
            PromptField(placeholder: "Press '/' for commands...", text: $value)
                .frame(height: Spacing.spacing7.rawValue)
                .font(.title3)
                .foregroundColor(ColorPalette.primaryText)
                .onSubmit {
                    if value == "" {
                        if let enterAction {
                            enterAction()
                        }
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
        }
        
    }
}

extension BlockView {

    func onSubmit(perform action: @escaping () -> Void) -> Self {
        self.enterAction = action
        return self
     }
}
