//
//  ContentView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var vm = ContentViewVM()
    @State private var settings = false
    @State private var menuOpen = true
    @State private var initialized = false
    
    var body: some View {
        SplitView(sidebarOpen: $menuOpen) {
            #if os(macOS)
            SidebarView(items: $vm.treeItems, settingsOpen: $settings, workspaceTitles: vm.workspaces.map{$0.title}, selectedWorkspaceTitleIndex: $vm.selectedWorkspaceIndex, selectedSubItem: $vm.selectedSubItem)
                .frame(width: GlobalDimension.treeWidth)
                .onChange(of: vm.selectedSubItem) { _ in
                    settings = false
                }
            #else
            
            SidebarView(items: $vm.treeItems, settingsOpen: $settings, workspaceTitles: vm.workspaces.map{$0.title}, selectedWorkspaceTitleIndex: $vm.selectedWorkspaceIndex, selectedSubItem: $vm.selectedSubItem)
                .background(colorScheme == .dark ? ColorPalette.darkSidebarMobile : ColorPalette.lightSidebarMobile)
                .onChange(of: vm.selectedSubItem) { _ in
                    settings = false
                    if UIDevice().userInterfaceIdiom == .phone {
                        if initialized {
                            withAnimation {
                                menuOpen = false
                            }
                        } else {
                            initialized = true
                        }
                    }
                }
            #endif
        } detail: {
            if settings {
                return SettingsView()
                    .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
            } else if let user = vm.user, let workspace = vm.selectedWorkspace, let document = vm.selectedDocument {
                return DocumentContainer(user: user, workspace: workspace, document: document)
                    .id(document.id)
            } else {
                return HorizontalFlexView {
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            } else {
                vm.initialize()
                vm.fetch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
