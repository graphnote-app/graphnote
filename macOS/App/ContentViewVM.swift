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

let wip = Label(id: UUID(), title: "WIP", color: LabelPalette.primary)
let monday = Label(id: UUID(), title: "Monday", color: LabelPalette.purple)
let client = Label(id: UUID(), title: "Client", color: LabelPalette.yellow)
let date = Label(id: UUID(), title: "3/24", color: LabelPalette.purple)
let stuff = Label(id: UUID(), title: "Stuff", color: LabelPalette.pink)
let web = Label(id: UUID(), title: "Web", color: LabelPalette.orangeLight)

let pages = [
    Page(id: page1, title: "Testing", labels: [
        wip,
        client,
        web,
        stuff,
    ]),
    Page(id: page2, title: "Testing 2", labels: [
        date,
        monday,
        web,
        stuff,
    ]),
    Page(id: page3, title: "Testing 3", labels: [
        wip,
        web,
        monday,
        stuff,
    ]),
    Page(id: page4, title: "Testing 4", labels: [
        wip,
        web,
        date,
        monday,
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
    }
}
