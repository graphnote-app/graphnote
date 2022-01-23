//
//  TreeViewItem.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

fileprivate enum Dimensions: CGFloat {
    case arrowWidthHeight = 12
    case rowPadding = 4
}

fileprivate let color = Color.gray

struct Title: Identifiable {
    let id: String
    let value: String
}

struct TreeViewItem: View {
    @State private var toggle = false
    let title: String
    let documentTitles: [Title]
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if toggle {
                    Arrow()
                        .frame(width: Dimensions.arrowWidthHeight.rawValue, height: Dimensions.arrowWidthHeight.rawValue)
                        .foregroundColor(color)
                        .rotationEffect(Angle(degrees: 90))
                } else {
                    Arrow()
                        .frame(width: Dimensions.arrowWidthHeight.rawValue, height: Dimensions.arrowWidthHeight.rawValue)
                        .foregroundColor(color)
                }
                FileIconView()
                    .padding(Dimensions.rowPadding.rawValue)
                Text(title)
                    .bold()
                    .padding(Dimensions.rowPadding.rawValue)
            }
            .padding(Dimensions.rowPadding.rawValue)
            .onTapGesture {
                toggle = !toggle
            }
        }
        
        
        if toggle {
            VStack(alignment: .leading) {
                ForEach(documentTitles) { title in
                    HStack {
                        BulletView()
                            .padding(Dimensions.rowPadding.rawValue)
                        Text(title.value)
                            .padding(Dimensions.rowPadding.rawValue)
                    }
                    
                }
            }
            .padding([.leading])
        }

    }
}

struct TreeViewItem_Previews: PreviewProvider {
    static var previews: some View {
        TreeViewItem(title: "Testing title", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
    }
}
