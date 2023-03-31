//
//  SplitView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct SplitView: View {
    @Binding var sidebarOpen: Bool
    
    let sidebar: () -> any View
    let detail: () -> any View
    
    var content: some View {
        GeometryReader { geometry in
            HStack(spacing: Spacing.spacing0.rawValue) {
                #if os(macOS)
                AnyView(sidebar())
                    .frame(width: !sidebarOpen ? .zero : nil)
                #else
                
                let portrait = OrientationInfo().orientation == .portrait
                let width = geometry.size.width
                let sidebarSizeMultiplier = portrait && width < 500 ? 0.85 : !portrait && width > 500 ? 0.25 : 0.35
                
                ZStack {
                    ColorPalette.lightSidebarMobile
                        .ignoresSafeArea()
                    AnyView(sidebar())
                }
                .frame(width: !sidebarOpen ? .zero : width * sidebarSizeMultiplier)
                
                #endif
                
                ToolbarView {
                    withAnimation {
                        self.sidebarOpen.toggle()
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
        SplitView(sidebarOpen: .constant(true)) {
            EmptyView()
        } detail: {
            EmptyView()
        }
    }
}
