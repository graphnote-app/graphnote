//
//  BulletView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/12/23.
//

import SwiftUI

fileprivate let bulletFontSize: CGFloat = 18.0

struct BulletView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: Spacing.spacing0.rawValue) {
            TreeDocView()
                .padding(Spacing.spacing3.rawValue)
            Spacer()
                .frame(width: Spacing.spacing3.rawValue)
            Text(text)
                .font(.system(size: bulletFontSize))
        }
    }
}

struct BulletView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            BulletView(text: "Bullet point number one")
            BulletView(text: "Bullet point number two")
            BulletView(text: "Bullet point number three")
            BulletView(text: "Bullet point number four")
        }.padding()
    }
}
