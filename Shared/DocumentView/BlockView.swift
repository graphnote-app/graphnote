//
//  BlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/23/23.
//

import SwiftUI

struct BlockView: View {
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
        VStack {
            ForEach(0..<nTopSpacers, id: \.self) { _ in
                Spacer().frame(height: Spacing.spacing5.rawValue)
            }
            TextField("Press '/' for commands...", text: $value)
                .disableAutocorrection(true)
                .textFieldStyle(.plain)
                .font(.title3)
                .foregroundColor(ColorPalette.primaryText)
                .onSubmit {
                    if value == "" {
                        nTopSpacers += 1
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
