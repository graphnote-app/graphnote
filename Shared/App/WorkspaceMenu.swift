//
//  WorkspaceMenu.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct WorkspaceMenu: View {
    @State private var selectedIndex = 0
    
    let workspaceTitles = ["Work", "Client", "Personal"]
    
    var body: some View {
        Menu(workspaceTitles[selectedIndex]) {
            ForEach(0..<workspaceTitles.count, id: \.self) { index in
                Button(workspaceTitles[index]) {
                    selectedIndex = index
                }
            }
        }.menuStyle(.borderlessButton)
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceMenu()
    }
}
