//
//  NavigationButtonView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/23/22.
//

import SwiftUI

struct NavigationButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    let width: CGFloat = 20
    let barHeight: CGFloat = 1.5
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: width, height: width)
                .foregroundColor(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
            VStack(spacing: 4) {
                Rectangle()
                    .frame(width: width, height: barHeight)
                Rectangle()
                    .frame(width: width, height: barHeight)
                Rectangle()
                    .frame(width: width, height: barHeight)
            }
            .foregroundColor(.primary)

        }
    }
}

struct NavigationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationButtonView()
    }
}
