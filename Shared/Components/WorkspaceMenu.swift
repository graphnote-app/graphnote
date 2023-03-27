//
//  WorkspaceMenu.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct WorkspaceMenu: View {
    @Binding var selectedIndex: Int
    
    let workspaceTitles: [String]
    
    var body: some View {
        if workspaceTitles.count > selectedIndex {
            Menu(workspaceTitles[selectedIndex]) {
                ForEach(0..<workspaceTitles.count, id: \.self) { index in
                    Button(workspaceTitles[index]) {
                        selectedIndex = index
                    }
                }
            }.menuStyle(.borderlessButton)
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceMenu(selectedIndex: .constant(0), workspaceTitles: ["test"])
    }
}
