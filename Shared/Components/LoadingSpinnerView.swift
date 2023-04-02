//
//  LoadingSpinnerView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI

struct LoadingSpinnerView: View {
    let width = Spacing.spacing8.rawValue
    
    var body: some View {
        Image(systemName: "gear")
            .resizable()
            .frame(width: width, height: width)
    }
}

struct LoadingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSpinnerView()
    }
}
