//
//  ContentViewVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import Foundation
import SwiftUI

class ContentViewVM: NSObject, ObservableObject {
    let ALL_ID = UUID()
    
    @Published var treeItems: [TreeViewItem] = []
    @Published var selectedDocument: Document? = nil {
        didSet {
            print("SELECTED DOCUMENT DID SET")
        }
    }
    @Published var workspaces: [Workspace]? = nil
    
    @Published var selectedWorkspace: Workspace? = nil {
        didSet {
            if selectedWorkspace != oldValue {
                if let user = user {
                    if let workspace = selectedWorkspace {
                        let documentRepo = DocumentRepo(user: user, workspace: workspace)
                        if let documents = try? documentRepo.readAll(), let document = documents.first {
                            selectedDocument = document
                            if let selectedDocument, let selectedWorkspace {
                                selectedSubItem = TreeDocumentIdentifier(label: ALL_ID, document: selectedDocument.id, workspace: selectedWorkspace.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @Published var selectedWorkspaceIndex: Int = 0 {
        didSet {
            if selectedWorkspaceIndex != oldValue {
                if let workspaces {
                    if workspaces.count > selectedWorkspaceIndex {
                        selectedWorkspace = workspaces[selectedWorkspaceIndex]
                        fetch()
                    }
                }
            }
        }
    }
    @Published var selectedSubItem: TreeDocumentIdentifier? = nil {
        didSet {
            if selectedSubItem != nil {
                if let selectedSubItem, let user, let selectedWorkspace {
                    let workspaceRepo = WorkspaceRepo(user: user)
                    if let document = try? workspaceRepo.read(document: selectedSubItem.document, workspace: selectedWorkspace.id) {
                        self.selectedDocument = document
                    }
                    
                }
            }
        }
    }
    
    @Published var user: User? = nil

    @objc
    func methodOfReceivedNotification(notification: NSNotification) {
        fetch()
    }
    
    func initializeUser() {
        if let user = try? UserRepo().readAll()?.first {
            self.user = user
        }
    }
    
    func initializeUserWorkspaces() {
        if let user {
            let workspaceRepo = WorkspaceRepo(user: user)
            
            if let workspaces = try? workspaceRepo.readAll(), let workspace = workspaces.first {
                self.selectedWorkspace = selectedWorkspace ?? workspace
                self.selectedWorkspaceIndex = selectedWorkspace != nil ? selectedWorkspaceIndex : 0
                self.workspaces = self.workspaces ?? workspaces
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name(LabelNotification.newLabel.rawValue), object: nil)
            }
        }
    }
    
    private func updateCurrentWorkspace() {
        if let selectedWorkspace, let user {
            let workspaceRepo = WorkspaceRepo(user: user)
            let updatedWorkpace = try? workspaceRepo.read(workspace: selectedWorkspace.id)
            self.selectedWorkspace = updatedWorkpace
        }
    }
    
    private func updateCurrentDocument() {
        if let selectedDocument, let selectedWorkspace, let user {
            let workspaceRepo = WorkspaceRepo(user: user)
            let updatedDocument = try? workspaceRepo.read(document: selectedDocument.id, workspace: selectedWorkspace.id)
            self.selectedDocument = updatedDocument
        }
    }
    
    func addDocument(_ document: Document) -> Bool {
        if let user, let selectedWorkspace {
            do {
                try DataService.shared.createDocument(user: user, document: document)
                let now = Date.now
                let prompt = Block(id: UUID(), type: .body, content: "", prev: nil, next: nil, createdAt: now, modifiedAt: now, document: document)
                if try DataService.shared.createBlock(user: user, workspace: selectedWorkspace, document: document, block: prompt, prev: nil, next: nil) == nil {
                    return false
                }
                
                DataService.shared.updateDocumentFocused(user: user, workspace: selectedWorkspace, document: document, focused: prompt.id)
                
                if let selected = selectedSubItem {
                    selectedSubItem = TreeDocumentIdentifier(label: selected.label, document: document.id, workspace: selectedWorkspace.id)
                }
                return true
            } catch let error {
                print(error)
                return false
            }
            
        } else {
            return false
        }
    }
    
    func fetchDocument() {
        if selectedDocument != nil {
            updateCurrentDocument()
        }
    }
    
    func fetch() {
        if let user {
            
            let workspaceRepo = WorkspaceRepo(user: user)
            
            if let workspaces = try? workspaceRepo.readAll() {
                self.workspaces = workspaces
                if workspaces.count > selectedWorkspaceIndex {
                    let workspace = workspaces[selectedWorkspaceIndex]
                    self.workspaces = workspaces
                    if selectedWorkspace != nil {
                        updateCurrentWorkspace()
                    }

                    
                    let curWorkspace = self.selectedWorkspace ?? workspace
                    
                    self.selectedWorkspace = curWorkspace
                    
                    treeItems = curWorkspace.labels.map({ label in
                        
                        let workspaceRepo = WorkspaceRepo(user: user)
                        let labelLinks = try? workspaceRepo.readLabelLinks(workspace: curWorkspace).filter {
                            return $0.label == label.id
                        }
                        
                        let subItems = labelLinks?.compactMap { labelLink in
                            do {
                                if let document = try workspaceRepo.read(document: labelLink.document, workspace: labelLink.workspace) {
                                    return TreeViewSubItem(id: document.id, title: document.title)
                                }
                            } catch let error {
                                print(error)
                            }
                            
                            return nil
                        }
                        
                        return TreeViewItem(id: label.id, workspace: workspace.id, title: label.title, color: label.color.getColor(), subItems: subItems)
                    }).sorted(by: { lhs, rhs in
                        lhs.title < rhs.title
                    })
                    
                    treeItems.append(
                        TreeViewItem(id: ALL_ID, workspace: workspace.id, title: "ALL", color: Color.gray, subItems: curWorkspace.documents.map {
                            TreeViewSubItem(id: $0.id, title: $0.title)
                        })
                    )
                }
            } else {
                if let selectedWorkspace {
                    treeItems.append(
                        TreeViewItem(id: ALL_ID, workspace: selectedWorkspace.id, title: "ALL", color: Color.gray, subItems: nil)
                    )
                }
            }
        } else {
            if let selectedWorkspace {
                treeItems.append(
                    TreeViewItem(id: ALL_ID, workspace: selectedWorkspace.id, title: "ALL", color: Color.gray, subItems: nil)
                )
            }
            
        }
    }
}
