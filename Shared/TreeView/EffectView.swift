//
//  EffectView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/26/22.
//

import SwiftUI

#if os(macOS)

struct NSEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView(frame: CGRect(x: 0, y: 0, width: treeWidth, height: TreeViewItemDimensions.arrowWidthHeight.rawValue))
        view.material = .windowBackground
        view.blendingMode = .withinWindow
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}

#else

struct UIEffectView: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

#endif

struct EffectView: View {
    var body: some View {
        #if os(macOS)
        NSEffectView()
        #else
        UIEffectView()
        #endif
    }
}
