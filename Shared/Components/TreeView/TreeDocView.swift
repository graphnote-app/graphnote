//
//  TreeDocView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

fileprivate enum Dimensions: CGFloat {
    case bulletDiameter = 6
}

struct TreeDocView: View {
    var body: some View {
        Image(systemName: "doc.plaintext")
            .frame(width: Dimensions.bulletDiameter.rawValue, height: Dimensions.bulletDiameter.rawValue)
            .foregroundColor(Color.accentColor)
    }
}

struct TreeBulletView_Previews: PreviewProvider {
    static var previews: some View {
        TreeDocView()
    }
}
