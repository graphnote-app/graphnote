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
    
    @State private var menuOpen = true
    
    var body: some View {
        HStack(spacing: Spacing.spacing0.rawValue) {
            if menuOpen {
                AnyView(sidebar())
            }
            
            ToolbarView {
                self.menuOpen.toggle()
            }
            
            AnyView(detail())
        }
        .edgesIgnoringSafeArea(.all)
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
