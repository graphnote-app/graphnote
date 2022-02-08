//
//  LoadingView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/7/22.
//

import SwiftUI

struct LoadingView: View {
    @State private var opacity = 0.2
        
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("Loading...")
                    .font(.largeTitle)
                    .opacity(opacity)
                    .padding()
                    .task {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            opacity += 0.8
                        }
                    }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
