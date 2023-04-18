//
//  BlockViewContainer.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

struct BlockViewContainer: View {
    let user: User
    let workspace: Workspace
    let document: Document
    let blocks: [Block]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(blocks, id: \.id) { block in
                BlockView(user: user, workspace: workspace, document: document, block: block) {
                    
                }
                
            }
            
        }
        .fixedSize(horizontal: false, vertical: true)
        .submitScope()
    }
}

//struct BlockViewContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        BlockViewContainer()
//    }
//}
