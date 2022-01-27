//
//  TreeViewAddView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/26/22.
//

import SwiftUI

struct TreeViewAddView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            EffectView()
            Image(systemName: "plus")
                .padding(4)
        }
    }
}

struct TreeViewAddView_Previews: PreviewProvider {
    static var previews: some View {
        TreeViewAddView()
    }
}
