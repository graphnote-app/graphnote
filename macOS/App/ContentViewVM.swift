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

// A variable to control the label colors.
let STATIC_COLORS = false

let color1 = STATIC_COLORS ? LabelPalette.pink : LabelPalette.allColors.randomElement()!
let color2 = STATIC_COLORS ? LabelPalette.purple :LabelPalette.allColors.randomElement()!
let color3 = STATIC_COLORS ? LabelPalette.orangeLight :LabelPalette.allColors.randomElement()!
let color4 = STATIC_COLORS ? LabelPalette.orangeDark :LabelPalette.allColors.randomElement()!
let color5 = STATIC_COLORS ? LabelPalette.primary :LabelPalette.allColors.randomElement()!
let color6 = STATIC_COLORS ? LabelPalette.yellow :LabelPalette.allColors.randomElement()!

let wip = Label(id: UUID(), title: "WIP", color: color1)
let monday = Label(id: UUID(), title: "Monday", color: color2)
let client = Label(id: UUID(), title: "Client", color: color3)
let date = Label(id: UUID(), title: "3/24", color: color4)
let stuff = Label(id: UUID(), title: "Stuff", color: color5)
let web = Label(id: UUID(), title: "Web", color: color6)

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
