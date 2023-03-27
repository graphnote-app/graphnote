//
//  ContentViewVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import Foundation
import SwiftUI
import Cocoa

struct Page {
    let id: UUID
    let title: String
    var labels: [Label]
}

let page1 = UUID()
let page2 = UUID()
let page3 = UUID()
let page4 = UUID()

let pages = [
    Page(id: page1, title: "New thing", labels: [

    ]),
    Page(id: page2, title: "Design Doc", labels: [

    ]),
    Page(id: page3, title: "Experimental", labels: [

    ]),
    Page(id: page4, title: "Demo Day", labels: [

    ]),
]

class ContentViewVM: ObservableObject {
    @Published var treeItems: [TreeViewItem] = []
    @Published var selectedPage: Page = pages[0]
    @Published var workspaceTitles: [String] = []
    
    func fetch() {
        if let user = try? UserRepo().readAll()?.first {
            print(user)
            let workspaceRepo = WorkspaceRepo(user: user)
            if let workspaces = try? workspaceRepo.readAll() {
                print(workspaces)
                workspaceTitles = workspaces.map {$0.title}
                print(workspaceTitles)
                
                if let workspace = workspaces.first {
                    print(workspace.labels)
                }
            }
        }
        
        treeItems.append(
            TreeViewItem(id: UUID(), title: "ALL", color: Color.gray, subItems: pages.map({ page in
                TreeViewSubItem(id: page.id, title: page.title)
            }))
        )
    }
}
