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
    
    @StateObject private var vm = BlockViewContainerVM()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<blocks.count) { i in
                let block = blocks.sorted(by: { blockA, blockB in
                    blockA.order < blockB.order
                })[i]
                
                BlockView(user: user, workspace: workspace, document: document, block: block) {
                    vm.insertBlock(index: i + 1, user: user, workspace: workspace, document: document)
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
