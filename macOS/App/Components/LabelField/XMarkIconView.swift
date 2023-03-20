//
//  XMarkIconView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct XMarkIconView: View {
    var body: some View {
        Image(systemName: "xmark")
            .renderingMode(.template)
            .resizable()
            .foregroundColor(Color.red)
            .frame(width: GlobalDimension.iconSmall, height: GlobalDimension.iconSmall)
    }
}

struct XMarkIconView_Previews: PreviewProvider {
    static var previews: some View {
        XMarkIconView()
    }
}
