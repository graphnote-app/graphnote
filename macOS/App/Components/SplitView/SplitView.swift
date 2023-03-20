//
//  SplitView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct SplitView: View {
    let sidebar: () -> any View
    let detail: () -> any View
    
    let width = Spacing.spacing4.rawValue + (Spacing.spacing2.rawValue * 2)
    
    var body: some View {
        HStack(spacing: Spacing.spacing0.rawValue) {
            AnyView(sidebar())
            ToolbarView()
            AnyView(detail())
            Spacer(minLength: width)
        }
    }
}

struct SplitView_Previews: PreviewProvider {
    static var previews: some View {
        SplitView {
            EmptyView()
        } detail: {
            EmptyView()
        }
    }
}
