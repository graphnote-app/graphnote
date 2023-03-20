//
//  CheckmarkIconView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct CheckmarkIconView: View {
    var body: some View {
        Image(systemName: "checkmark")
            .renderingMode(.template)
            .resizable()
            .foregroundColor(Color.green)
            .frame(width: GlobalDimension.iconSmall, height: GlobalDimension.iconSmall)
    }
}

struct CheckmarkIconView_Previews: PreviewProvider {
    static var previews: some View {
        CheckmarkIconView()
    }
}
