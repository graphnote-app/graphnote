//
//  EditIconView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct EditIconView: View {
    var body: some View {
        Image(systemName: "pencil")
            .renderingMode(.template)
            .resizable()
            .frame(width: GlobalDimension.iconSmall, height: GlobalDimension.iconSmall)
    }
}

struct EditIconView_Previews: PreviewProvider {
    static var previews: some View {
        EditIconView()
    }
}
