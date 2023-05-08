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
    
    var font: Font {
        switch type {
        case .body:
            return .custom("", size: PromptFontDimensions.bodyFontSize, relativeTo: .body)
        default:
            return .subheadline
        }
    }

    var body: some View {
        Text(block.content)
            .font(font)
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
            .padding([.top, .bottom], Spacing.spacing2.rawValue)
    }
}
