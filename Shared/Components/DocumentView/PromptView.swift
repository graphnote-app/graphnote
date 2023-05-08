//
//  PromptView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 5/7/23.
//

import SwiftUI

struct PromptView: View {
    let id: UUID
    let type: BlockType
    let block: Block
    let selected: Bool
    
    var font: Font {
        switch type {
        default:
            return .custom("", size: PromptFontDimensions.bodyFontSize, relativeTo: .body)
        }
    }

    var body: some View {
        Text(block.content)
            .font(font)
            .lineSpacing(Spacing.spacing2.rawValue)
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
            .padding([.top, .bottom], Spacing.spacing2.rawValue)
            .overlay {
                if selected {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(LabelPalette.primary.getColor())
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LabelPalette.primary.getColor().opacity(0.125))
                    }
                }
            }
    }
}
