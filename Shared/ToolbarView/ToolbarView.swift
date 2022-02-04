//
//  ToolbarView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/23/22.
//

import SwiftUI

struct ToolbarView: View {
    @Environment(\.colorScheme) var colorScheme
    let size: CGSize
    let open: Binding<Bool>
    
    var body: some View {
        HStack {
            if !open.wrappedValue {
                #if os(macOS)
                Spacer()
                    .frame(width: 268)
                #else
                Spacer()
                    .frame(width: 10)
                #endif
                
            } else {
                Spacer()
                    .frame(width: 10)
            }
            NavigationButtonView()
                .padding(4)
                .onTapGesture {
                    open.wrappedValue = !open.wrappedValue
                }
            Spacer()
            
        }.zIndex(1)
            .background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
            .frame(width: size.width)
    }
}
