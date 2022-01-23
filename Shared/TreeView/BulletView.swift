//
//  BulletView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

fileprivate enum Dimensions: CGFloat {
    case bulletDiameter = 6
}

struct BulletView: View {
    var body: some View {
        Circle()
            .frame(width: Dimensions.bulletDiameter.rawValue, height: Dimensions.bulletDiameter.rawValue)
            .foregroundColor(Color.gray)
    }
}

struct BulletView_Previews: PreviewProvider {
    static var previews: some View {
        BulletView()
    }
}
