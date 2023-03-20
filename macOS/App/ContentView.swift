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
            SidebarView(selectedDocument: $vm.selectedDocument)
                .frame(width: GlobalDimension.treeWidth)
        } detail: {
            DocumentView(title: $vm.selectedDocumentTitle, labels: $vm.selectedDocumentLabels)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
