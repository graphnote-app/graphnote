//
//  ContentViewVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import Foundation
import SwiftUI

struct Label: Hashable {
    let id: UUID
    let title: String
    let color: Color
}

struct Page {
    let id: UUID
    let title: String
    var labels: [Label]
}

let page1 = UUID()
let page2 = UUID()
let page3 = UUID()
let page4 = UUID()

let wip = Label(id: UUID(), title: "WIP", color: LabelPalette.pink)
let monday = Label(id: UUID(), title: "Monday", color: LabelPalette.purple)
let client = Label(id: UUID(), title: "Client", color: LabelPalette.orangeLight)
let date = Label(id: UUID(), title: "3/24", color: LabelPalette.orangeDark)
let stuff = Label(id: UUID(), title: "Stuff", color: LabelPalette.primary)
let web = Label(id: UUID(), title: "Web", color: LabelPalette.yellow)

let pages = [
    Page(id: page1, title: "New thing", labels: [
        wip,
        client,
        web,
        stuff,
    ]),
    Page(id: page2, title: "Design Doc", labels: [
        date,
        monday,
        web,
    ]),
    Page(id: page3, title: "Experimental", labels: [
        wip,
        web,
        monday,
        stuff,
    ]),
    Page(id: page4, title: "Demo Day", labels: [
        wip,
        web,
        date,
    ]),
]

class ContentViewVM: ObservableObject {
    @Published var treeItems: [TreeViewItem] = []
    @Published var selectedPage: Page = pages[0]
    
    init() {
        let labels = Set(pages.flatMap {
            $0.labels
        })
        
        treeItems = labels.map({ label in
            return TreeViewItem(id: label.id, title: label.title, color: label.color, subItems: pages.filter({ page in
                page.labels.contains(label)
            }).map {
                TreeViewSubItem(id: $0.id, title: $0.title)
            })
        })
        
        treeItems.append(
            TreeViewItem(id: UUID(), title: "ALL", color: .gray, subItems: pages.map({ page in
                TreeViewSubItem(id: page.id, title: page.title)
            }))
        )
    }
}
