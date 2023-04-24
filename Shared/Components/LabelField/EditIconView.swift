//
//  AddIconView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct AddIconView: View {
    var body: some View {
        Image(systemName: "tag")
            .renderingMode(.template)
            .resizable()
            .frame(width: GlobalDimensionIOS.iconSmall, height: GlobalDimensionIOS.iconSmall)
    }
}

struct AddIconView_Previews: PreviewProvider {
    static var previews: some View {
        AddIconView()
    }
}
