//
//  SplitView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct SplitView: View {
    @Binding var sidebarOpen: Bool
    let syncStatus: SyncServiceStatus
    
    let sidebar: () -> any View
    let detail: () -> any View
    let retrySync: () -> Void
    

    var drag: some Gesture {
        DragGesture()
            .onEnded { _ in
                withAnimation {
                    self.sidebarOpen.toggle()
                }
            }
    }
    
    var content: some View {
        GeometryReader { geometry in
            HStack(spacing: Spacing.spacing0.rawValue) {
                #if os(macOS)
                if sidebarOpen {
                    AnyView(sidebar())
                        .frame(width: !sidebarOpen ? .zero : nil)
                }
                ToolbarView {
                    MenuCardView()
                } action: {
//                    withAnimation {
                        self.sidebarOpen.toggle()
//                    }
                    
                }
                
                #else
                
                let portrait = MobileUtils.OrientationInfo().orientation == .portrait
                let width = geometry.size.width
                let sidebarSizeMultiplier = portrait && width < 500 ? 0.85 : 0.35
                let finalWidth = width * sidebarSizeMultiplier
                if sidebarOpen {
                    ZStack {
                        ColorPalette.lightSidebarMobile
                            .ignoresSafeArea()
                        AnyView(sidebar())
                            .frame(maxWidth: GlobalDimension.treeWidth)
                            .frame(width: !sidebarOpen ? .zero : finalWidth < GlobalDimension.treeWidth ? finalWidth : GlobalDimension.treeWidth)
                    }
                    .frame(maxWidth: GlobalDimension.treeWidth)
                    .frame(width: !sidebarOpen ? .zero : finalWidth < GlobalDimension.treeWidth ? finalWidth : GlobalDimension.treeWidth)
                }
                
                ToolbarView {
                    MenuCardView()
                } action: {
                    withAnimation {
                        self.sidebarOpen.toggle()
                    }
                }
                .gesture(drag)
                .onTapGesture {
                    if sidebarOpen {
                        withAnimation {
                            self.sidebarOpen.toggle()
                        }
                    }
                }
                #endif
                
                AnyView(detail())
                    .overlay(alignment: .trailing) {
                        VStack(spacing: .zero) {
                            Spacer()
                            SyncStatusIconView(status: syncStatus)
                                .padding(Spacing.spacing3.rawValue)
                                .onTapGesture(perform: retrySync)
                            
                        }
                        
                    }
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
        SplitView(sidebarOpen: .constant(true), syncStatus: .success) {
            EmptyView()
        } detail: {
            EmptyView()
        } retrySync: {
            
        }
    }
}
