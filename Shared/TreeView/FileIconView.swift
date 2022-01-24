//
//  FileIconView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

struct FileIconView: View {
    var body: some View {
        Image(systemName: "doc.plaintext")
//            .foregroundColor(Color(red: 94 / 255.0, green: 129 / 255.0, blue: 255 / 255.0, opacity: 1.0))
            .foregroundColor(Color.purple)
    }
}

struct FileIconView_Previews: PreviewProvider {
    static var previews: some View {
        FileIconView()
    }
}
