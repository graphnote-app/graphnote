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
//    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var vm = ContentViewVM()
    @State private var settings = false
    #if os(macOS)
    @State private var menuOpen = true
    #else
    @State private var menuOpen = false
    #endif
    @State private var initialized = false
    
    @State private var globalUIState = AppGlobalUIState.loading
    @State private var newDocFailedAlert = false
    
    private let loadingDelay = 1.0
    
    func checkAuthStatus(user: User) {
        AuthService.checkAuthStatus(user: user) { state in
            withAnimation {
                print(state == .authorized)
                if state == .authorized {
                    globalUIState = .doc
                } else {
                    globalUIState = .signIn
                }
            }
        }
    }
    
    var body: some View {
        Group {
            switch globalUIState {
            case .loading:
                LoadingView()
            case .signIn:
                SignInView {
                    vm.initializeUser()
                    if let user = vm.user {
                        if seed {
                            if DataSeeder.seed(userId: user.id) {
                                vm.initializeUserWorkspaces()
                                vm.fetch()
                            } else {
                                print("seed failed")
                            }
                        } else {
                            vm.initializeUserWorkspaces()
                            vm.fetch()
                        }
                        
                        self.initialized = true
                        checkAuthStatus(user: user)
                    }
                }
            case .doc, .settings:
                SplitView(sidebarOpen: $menuOpen) {
                    #if os(macOS)
                    if let workspaces = vm.workspaces {
                        return SidebarView(
                            items: $vm.treeItems,
                            settingsOpen: $settings,
                            workspaceTitles: workspaces.map{$0.title},
                            selectedWorkspaceTitleIndex: $vm.selectedWorkspaceIndex,
                            selectedSubItem: $vm.selectedSubItem
                        ) {
                            let document = Document(id: UUID(), title: "New Doc", createdAt: .now, modifiedAt: .now)
                            if !vm.addDocument(document) {
                                newDocFailedAlert = true
                            } else {
                                vm.fetch()
                            }
                        }
                        .alert("New Doc Failed", isPresented: $newDocFailedAlert, actions: {
                            Text("Document failed to create")
                        })
                        .frame(width: GlobalDimension.treeWidth)
                        .onChange(of: vm.selectedSubItem) { _ in
                            settings = false
                        }
                        
                    } else {
                        return EmptyView()
                    }
                    #else
                    
                    if let workspaces = vm.workspaces {
                        return SidebarView(
                            items: $vm.treeItems,
                            settingsOpen: $settings,
                            workspaceTitles: workspaces.map{$0.title},
                            selectedWorkspaceTitleIndex: $vm.selectedWorkspaceIndex,
                            selectedSubItem: $vm.selectedSubItem
                        )
                        .background(colorScheme == .dark ? ColorPalette.darkSidebarMobile : ColorPalette.lightSidebarMobile)
                        .onChange(of: vm.selectedSubItem) { _ in
                            settings = false
                            if UIDevice().userInterfaceIdiom == .phone {
                                if MobileUtils.OrientationInfo().orientation == .portrait {
                                    withAnimation {
                                        menuOpen = false
                                    }
                                }
                            }
                        }
                        .onChange(of: menuOpen) { newValue in
                            if newValue == true {
                                MobileUtils.resignKeyboard()
                            }
                        }
                        
                    } else {
                        return EmptyView()
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
            }
        } 
//        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { notification in
//            print("scenePhase notification: \(notification)")
//        }
//        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { notification in
//            print("scenePhase notification: \(notification)")
//        }
        .onAppear {
            if DataController.shared.loaded {
                if !initialized {
                    vm.initializeUser()
                    vm.initializeUserWorkspaces()
                    if let user = vm.user {
                        DispatchQueue.main.asyncAfter(deadline: .now() + loadingDelay) {
                            checkAuthStatus(user: user)
                            vm.fetch()
                            withAnimation {
                                globalUIState = .signIn
                            }
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + loadingDelay) {
                            withAnimation {
                                globalUIState = .signIn
                            }
                        }
                    }
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
