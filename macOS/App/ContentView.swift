//
//  ContentView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ContentViewVM()
    
    var body: some View {
        SplitView {
            SidebarView(items: $vm.treeItems)
                .frame(width: GlobalDimension.treeWidth)
        } detail: {
            DocumentView(title: .constant("Testing"), labels: $vm.selectedPage.labels)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
