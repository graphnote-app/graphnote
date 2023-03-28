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
    @Published var treeItems: [TreeViewItem] = []
    @Published var workspaceTitles: [String] = []
    
    func fetch() {
        if let user = try? UserRepo().readAll()?.first {
            
            let workspaceRepo = WorkspaceRepo(user: user)
            if let workspaces = try? workspaceRepo.readAll() {
                workspaceTitles = workspaces.map {$0.title}
            
                if let workspace = workspaces.first {
                    treeItems = workspace.labels.map({ label in
                        let documents = try? workspaceRepo.readLabelLinks(workspace: workspace).filter {
                            $0.label == label.id
                        }
                        
                        let subItems = documents?.compactMap {
                            if let document = try? workspaceRepo.read(document: $0.document) {
                                return TreeViewSubItem(id: document.id, title: document.title)
                            } else {
                                return nil
                            }
                        }
                        
                        return TreeViewItem(id: label.id, title: label.title, color: label.color, subItems: subItems)
                    })
                    
                    treeItems.append(
                        TreeViewItem(id: UUID(), title: "ALL", color: Color.gray, subItems: workspace.documents.map {
                            TreeViewSubItem(id: $0.id, title: $0.title)
                        })
                    )
                }
            }
            
        }
        
        
    }
}
