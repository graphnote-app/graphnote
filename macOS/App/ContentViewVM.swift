//
//  ContentViewVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import Foundation
import SwiftUI
import Cocoa

class ContentViewVM: ObservableObject {
    private let ALL_ID = UUID()
    
    @Published var treeItems: [TreeViewItem] = []
    @Published var selectedDocument: Document? = nil {
        didSet {
            if let selectedWorkspace, let selectedDocument, let user {
                let documentRepo = DocumentRepo(user: user, workspace: selectedWorkspace)
                if let labels = documentRepo.readLabels(document: selectedDocument) {
                    self.selectedDocumentLabels = labels
                }
                
                if let blocks = try? documentRepo.readBlocks(document: selectedDocument) {
                    self.selectedDocumentBlocks = blocks
                }
            }
        }
    }
    
    @Published var selectedDocumentLabels: [Label] = []
    
    @Published var selectedDocumentTitle: String = "" {
        didSet {
            updateDocumentTitle(selectedDocumentTitle)
            fetch()
        }
    }
    
    @Published var selectedDocumentBlocks: [Block] = []
    @Published var workspaces: [Workspace] = []
    @Published var selectedWorkspace: Workspace? = nil
    
    @Published var selectedWorkspaceIndex: Int = 0 {
        didSet {
            if workspaces.count > selectedWorkspaceIndex {
                selectedWorkspace = workspaces[selectedWorkspaceIndex]
                fetch()
            }
        }
    }
    @Published var selectedSubItem: TreeDocumentIdentifier? = nil {
        didSet {
            if let selectedSubItem, let user {
                let workspaceRepo = WorkspaceRepo(user: user)
                if let document = try? workspaceRepo.read(document: selectedSubItem.document) {
                    selectedDocument = document
                    selectedDocumentTitle = document.title
                }
                
            }
        }
    }
    
    @Published var user: User? = nil

    func initialize() {
        if let user = try? UserRepo().readAll()?.first {
            
            self.user = user
            
            let workspaceRepo = WorkspaceRepo(user: user)
            
            if let workspaces = try? workspaceRepo.readAll(), let workspace = workspaces.first {
                selectedWorkspace = workspace
                self.selectedWorkspaceIndex = 0
                self.workspaces = workspaces
                
                let documentRepo = DocumentRepo(user: user, workspace: workspace)
                if let documents = try? documentRepo.readAll(), let document = documents.first {
                    selectedDocument = document
                    selectedDocumentTitle = document.title
                    if let selectedDocument {
                        selectedSubItem = TreeDocumentIdentifier(label: ALL_ID, document: selectedDocument.id)
                    }
                }
            }
        }
    }
    
    func updateDocumentTitle(_ title: String) {
        if let selectedWorkspace, let selectedDocument, let user {
            let documentRepo = DocumentRepo(user: user, workspace: selectedWorkspace)
            documentRepo.update(document: selectedDocument, title: title)
        }
    }
    
    func fetch() {
        if let user {
            
            let workspaceRepo = WorkspaceRepo(user: user)
            
            if let workspaces = try? workspaceRepo.readAll() {
                let workspace = workspaces[selectedWorkspaceIndex]
                selectedWorkspace = workspace
                treeItems = workspace.labels.map({ label in
                    
                    let workspaceRepo = WorkspaceRepo(user: user)
                    let labelLinks = try? workspaceRepo.readLabelLinks(workspace: workspace).filter {
                        $0.label == label.id
                    }
                    
                    let subItems = labelLinks?.compactMap { labelLink in
                        do {
                            if let document = try workspaceRepo.read(document: labelLink.document) {
                                return TreeViewSubItem(id: document.id, title: document.title)
                            }
                        } catch let error {
                            print(error)
                        }
                        
                        return nil
                    }
                    
                    return TreeViewItem(id: label.id, title: label.title, color: label.color, subItems: subItems)
                })
                
                treeItems.append(
                    TreeViewItem(id: ALL_ID, title: "ALL", color: Color.gray, subItems: workspace.documents.map {
                        TreeViewSubItem(id: $0.id, title: $0.title)
                    })
                )
            } else {
                treeItems.append(
                    TreeViewItem(id: ALL_ID, title: "ALL", color: Color.gray, subItems: nil)
                )
            }
        } else {
            treeItems.append(
                TreeViewItem(id: ALL_ID, title: "ALL", color: Color.gray, subItems: nil)
            )
        }
    }
}
