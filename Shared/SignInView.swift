//
//  SignInView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI

struct SignInView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("GraphnoteIcon")
            
                .frame(width: 80, height: 80)
            Text("Graphnote")
                .font(.title)
            Spacer()
//            AppleSignInButton()
//                .frame(width: 200, height: 50)
            Spacer()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
