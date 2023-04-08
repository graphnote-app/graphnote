//
//  SyncStatusIconView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 4/8/23.
//

import SwiftUI

struct SyncStatusIconView: View {
    let diameter = Spacing.spacing4.rawValue
    let status: SyncServiceStatus
    
    var color: Color {
        switch status {
        case .paused:
            return LabelColor.primary
        case .failed:
            return LabelColor.red
        case .success:
            return LabelColor.limeGreen
            
        }
    }
    
    var body: some View {
        Image(systemName: "wifi.circle")
            .renderingMode(.template)
            .resizable()
            .frame(width: diameter, height: diameter)
            .foregroundColor(color)
    }
}

struct SyncStatusIconView_Previews: PreviewProvider {
    static var previews: some View {
        SyncStatusIconView(status: .success)
        SyncStatusIconView(status: .failed)
        SyncStatusIconView(status: .paused)
    }
}
