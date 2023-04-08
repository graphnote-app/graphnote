//
//  MenuCardView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct MenuCardView: View {
    let diameter = Spacing.spacing4.rawValue
    
    var body: some View {
        Image(systemName: "menucard")
            .resizable()
            .frame(width: diameter, height: diameter)
    }
}

struct MenuCardView_Previews: PreviewProvider {
    static var previews: some View {
        MenuCardView()
    }
}
