//
//  GearIconVIew.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/21/23.
//

import SwiftUI

struct GearIconVIew: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "gear")
        }
        .buttonStyle(.plain)
    }
}

struct GearIconVIew_Previews: PreviewProvider {
    static var previews: some View {
        GearIconVIew() {
            
        }
    }
}
