//
//  ContentView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var vm = ContentViewVM()
    @State private var settings = false
    
    
    private func contentFlex(v: some View) -> some View {
        HStack {
            Spacer()
            v.frame(minWidth: GlobalDimension.minDocumentContentWidth)
             .frame(maxWidth: GlobalDimension.maxDocumentContentWidth)
            Spacer()
        }
        .padding([.top, .bottom])
    }
    
    var body: some View {
        SplitView {
            SidebarView(items: $vm.treeItems, settingsOpen: $settings, workspaceTitles: vm.workspaces.map{$0.title}, selectedWorkspaceTitleIndex: $vm.selectedWorkspaceIndex)
                .frame(width: GlobalDimension.treeWidth)
        } detail: {
            if settings {
                return SettingsView()
                    .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
                
            } else {
                return DocumentView(title: .constant("Testing"), labels: .constant([]))
                    .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
            }
        }
        .onAppear {
            if seed {
                if DataSeeder.seed() {
                    vm.initialize()
                    vm.fetch()
                } else {
                    print("seed failed")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
