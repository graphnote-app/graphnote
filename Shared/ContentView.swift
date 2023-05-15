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

import Combine

let seed = false

// Comment out this line to remove the linked list node viewer
public let DEBUG_VISUAL_LINKED_LIST = true

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
    
    @State private var seeding = false
    @State private var seeded = false
    
    @State private var globalUIState = AppGlobalUIState.loading
    @State private var newDocFailedAlert = false
    @State private var networkSyncFailedAlert = false
    @State private var syncStatus: SyncServiceStatus = .success
    
    private let loadingDelay = 1.0
    private let networkSyncSuccessNotification = Notification.Name(SyncServiceNotification.networkSyncSuccess.rawValue)
    private let networkSyncFailedNotification = Notification.Name(SyncServiceNotification.networkSyncFailed.rawValue)
    private let networkMessageIDsFetchedNotification = Notification.Name(SyncServiceNotification.messageIDsFetched.rawValue)
    private let localWorkspaceCreatedNotification = Notification.Name(SyncServiceNotification.workspaceCreated.rawValue)
    private let localDocumentCreatedNotification = Notification.Name(SyncServiceNotification.documentCreated.rawValue)
    private let documentUpdateSyncedNotification = Notification.Name(SyncServiceNotification.documentUpdateSynced.rawValue)
    private let localDocumentUpdatedNotification = Notification.Name(DataServiceNotification.documentUpdatedLocally.rawValue)
    private let documentUpdateReceivedNotification = Notification.Name(SyncServiceNotification.documentUpdateReceived.rawValue)
    private let workspaceCreatedNotification = Notification.Name(SyncServiceNotification.workspaceCreated.rawValue)
    private let labelLinkCreatedNotification = Notification.Name(DataServiceNotification.labelLinkCreated.rawValue)
    private let labelCreatedNotification = Notification.Name(DataServiceNotification.labelCreated.rawValue)
    private let userCreatedNotification = Notification.Name(SyncServiceNotification.userSyncCreated.rawValue)
    
    func checkAuthStatus(user: User) {
        AuthService.checkAuthStatus(user: user) { state in
            withAnimation {
                print(state == .authorized)
                DispatchQueue.main.async {
                    if state == .authorized {
                        globalUIState = .doc
                        DataService.shared.startWatching(user: user)
                    } else {
                        globalUIState = .signIn
                    }
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
                SignInView { isSignUp, user, success in
                    
                    if success {
                        if let user = user {
                            if isSignUp {
                                DataService.shared.setup(user: user)
                                DataService.shared.startWatching(user: user)
                                
                                seeding = true
                                if DataSeeder.seed(user: user) {
                                    vm.initializeUser()
                                    vm.initializeUserWorkspaces()
                                    vm.fetch()
                                    
                                } else {
                                    print("seed failed")
                                }
                                
                                seeding = false
                                
                            } else {
                                DataService.shared.setup(user: user)
                                DataService.shared.startWatching(user: user)
                                vm.initializeUser()
                                vm.initializeUserWorkspaces()
                                vm.fetch()
                            }
                            
                            DataService.shared.fetchMessageIDs(user: user)
                            self.initialized = true
                            checkAuthStatus(user: user)
                        }
                    } else {
                        print("Failed to login")
                    }
                }
                .onAppear {
                    if let user = vm.user {
                        DataService.shared.fetchMessageIDs(user: user)
                    }
                }
            case .doc, .settings:
                SplitView(sidebarOpen: $menuOpen, syncStatus: syncStatus) {
                    #if os(macOS)
                    if let workspace = vm.selectedWorkspace {
                        return SidebarView(
                            items: $vm.treeItems,
                            settingsOpen: $settings,
                            workspaceTitles: vm.workspaces!.map{$0.title},
                            selectedWorkspaceTitleIndex: $vm.selectedWorkspaceIndex,
                            selectedSubItem: $vm.selectedSubItem,
                            allID: vm.ALL_ID
                        ) {
                            let document = Document(id: UUID(), title: "New Doc", focused: vm.selectedDocument?.focused, createdAt: .now, modifiedAt: .now, workspace: workspace.id)
                            if !vm.addDocument(document) {
                                newDocFailedAlert = true
                            } else {
                                vm.fetch()
                            }
                        } refresh: {
                            vm.fetch()
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
                    
                    if let workspaces = vm.workspaces, let workspace = vm.selectedWorkspace {
                        return SidebarView(
                            items: $vm.treeItems,
                            settingsOpen: $settings,
                            workspaceTitles: workspaces.map{$0.title},
                            selectedWorkspaceTitleIndex: $vm.selectedWorkspaceIndex,
                            selectedSubItem: $vm.selectedSubItem,
                            allID: vm.ALL_ID
                        ) {
                            let document = Document(id: UUID(), title: "New Doc", focused: vm.selectedDocument?.focused, createdAt: .now, modifiedAt: .now, workspace: workspace.id)
                           if !vm.addDocument(document) {
                               newDocFailedAlert = true
                           } else {
                               vm.fetch()
                           }
                        } refresh: {
                            vm.fetch()
                        }
                       .alert("New Doc Failed", isPresented: $newDocFailedAlert, actions: {
                           Text("Document failed to create")
                       })
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
                        if let user = vm.user {
                            return SettingsView(user: user)
                                .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
                        } else {
                            return EmptyView()
                        }
                    } else if let user = vm.user, let workspace = vm.selectedWorkspace, let document = vm.selectedDocument {
                        return DocumentContainer(user: user, workspace: workspace, document: document, onRefresh: {
                            vm.fetch()
                        })
                        .onChange(of: document, perform: { newValue in
                            vm.fetchDocument()
                        })
                        .id(vm.selectedDocument.hashValue)
                    } else {
                        return HorizontalFlexView {
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
                        
                    }
                } retrySync: {
                    if let user = vm.user {
                        DataService.shared.startWatching(user: user)
                        DataService.shared.fetchMessageIDs(user: user)
                    }
                }
                .onAppear {
                    if let user = vm.user {
                        DataService.shared.fetchMessageIDs(user: user)
                        vm.fetch()
                    }
                }
            }
        }
        .onChange(of: vm.user, perform: { newValue in
            if let newValue {
                DataService.shared.startWatching(user: newValue)
            }
        })
        .alert("Offline Mode", isPresented: $networkSyncFailedAlert, actions: {
            Button("Try to Connect") {
                networkSyncFailedAlert = false
                syncStatus = .success
                if let user = vm.user {
                    DataService.shared.startWatching(user: user)
                    DataService.shared.fetchMessageIDs(user: user)
                }
            }
            Button("Continue Offline") {
                syncStatus = .paused
                networkSyncFailedAlert = false
                DataService.shared.stopWatching()
            }
        }, message: {
            Text("Error: \(DataService.shared.error?.localizedDescription ?? "")\nOffline mode will continue until relaunch or tapping the wifi icon")
        })
        .onReceive(NotificationCenter.default.publisher(for: localDocumentUpdatedNotification)) { notification in
            DispatchQueue.main.async {
                vm.fetch()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: localWorkspaceCreatedNotification)) { notification in
            DispatchQueue.main.async {
                vm.fetch()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: localDocumentCreatedNotification)) { notification in
            DispatchQueue.main.async {
                vm.fetch()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: labelLinkCreatedNotification)) { notification in
            DispatchQueue.main.async {
                vm.fetch()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: documentUpdateSyncedNotification)) { notification in
        }
        .onReceive(NotificationCenter.default.publisher(for: labelLinkCreatedNotification)) { notification in
            DispatchQueue.main.async {
                vm.fetch()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: labelCreatedNotification)) { notification in
            DispatchQueue.main.async {
                vm.fetch()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: userCreatedNotification)) { notification in
            DispatchQueue.main.async {
                vm.initializeUser()
                if let user = vm.user {
                    DataService.shared.setup(user: user)
                    DataService.shared.startWatching(user: user)
                    vm.initializeUserWorkspaces()
                    vm.fetch()
                    vm.fetchDocument()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: networkMessageIDsFetchedNotification)) { notification in
            syncStatus = .success
        }
        .onReceive(NotificationCenter.default.publisher(for: documentUpdateReceivedNotification)) { notification in
            DispatchQueue.main.async {
                vm.fetch()
                vm.fetchDocument()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: networkSyncFailedNotification)) { notification in
            print("Network synced failed: \(notification)")
            networkSyncFailedAlert = true
            syncStatus = .failed
        }
        .onReceive(NotificationCenter.default.publisher(for: workspaceCreatedNotification)) { notification in
            if !seeding && seeded {
                vm.fetch()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: networkSyncSuccessNotification)) { notification in
            syncStatus = .success
            networkSyncFailedAlert = false
            if let user = vm.user {
                DataService.shared.startWatching(user: user)
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
                    
                    if let user = vm.user {
                        DataService.shared.setup(user: user)
                        DataService.shared.startWatching(user: user)
                        vm.initializeUserWorkspaces()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + loadingDelay) {
                            checkAuthStatus(user: user)
                        }
                        
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + loadingDelay) {
                            withAnimation {
                                globalUIState = .signIn
                            }
                        }
                    }
                } else {
                    if let user = vm.user {
                        checkAuthStatus(user: user)
                    }
                }
            }
        }
        .onDisappear {
            DataService.shared.stopWatching()
            AuthService.signOut()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
