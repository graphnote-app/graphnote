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
    
    var content: some View {
        GeometryReader { geometry in
            HStack(spacing: Spacing.spacing0.rawValue) {
                #if os(macOS)
                AnyView(sidebar())
                    .frame(width: !menuOpen ? .zero : nil)
                #else
                
                let portrait = OrientationInfo().orientation == .portrait
                let width = geometry.size.width
                let sidebarSizeMultiplier = portrait && width < 500 ? 0.75 : !portrait && width > 500 ? 0.25 : 0.35
                
                ZStack {
                    ColorPalette.lightSidebarMobile
                        .ignoresSafeArea()
                    AnyView(sidebar())
                }
                .frame(width: !menuOpen ? .zero : width * sidebarSizeMultiplier)
                
                #endif
                
                ToolbarView {
                    withAnimation {
                        self.menuOpen.toggle()
                    }
                }
                
                AnyView(detail())
            }
        }
    }
    
    var body: some View {
        #if os(macOS)
        content
            .edgesIgnoringSafeArea(.all)
        #else
        content
        #endif
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
