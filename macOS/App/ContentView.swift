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
            SidebarView()
                .frame(width: GlobalDimension.treeWidth)
        } detail: {
            DocumentView(title: $vm.selectedDocument, labels: $vm.selectedDocumentLabels)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
