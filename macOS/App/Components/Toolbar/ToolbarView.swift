//
//  ToolbarView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct ToolbarView: View {
    var body: some View {
        VStack {
            Spacer()
            MenuCardView()
                .padding(Spacing.spacing2.rawValue)
        }
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView()
    }
}
