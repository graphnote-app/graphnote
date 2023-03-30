//
//  SettingsView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/21/23.
//

import SwiftUI

struct SettingsView: View {
    private func contentFlex(v: some View) -> some View {
        HStack {
            Spacer()
            v.frame(minWidth: GlobalDimensionIOS.minDocumentContentWidth)
             .frame(maxWidth: GlobalDimensionIOS.maxDocumentContentWidth)
            Spacer()
        }
        .padding([.top, .bottom])
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: Spacing.spacing4.rawValue)
            HStack {
                Text("Account")
                    .font(.title)
                    .bold()
                Spacer()
            }
            Spacer()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            contentFlex(v: content)
                .frame(minHeight: geometry.size.height)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
