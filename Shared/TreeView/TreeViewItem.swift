//
//  TreeViewItem.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

fileprivate enum Dimensions: CGFloat {
    case arrowWidthHeight = 12
    case rowPadding = 4
}

fileprivate let color = Color.gray

struct Title: Identifiable {
    let id: String
    let value: String
    let selected: Bool
}

#if os(macOS)

struct NSEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView(frame: CGRect(x: 0, y: 0, width: treeWidth, height: Dimensions.arrowWidthHeight.rawValue))
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

struct TreeViewItem: View, Identifiable {
    @EnvironmentObject var treeViewModel: TreeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var toggle = false
    let id: String
    let title: String
    let documents: [Title]
    
    func innerCell(title: Title) -> some View {
        ZStack(alignment: .leading) {
            EffectView()
            HStack {
                BulletView()
                    .padding(Dimensions.rowPadding.rawValue)
                Text(title.value)
                    .padding(Dimensions.rowPadding.rawValue)
            }
        }
        
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                EffectView()
                HStack {
                    if toggle {
                        Arrow()
                            .frame(width: Dimensions.arrowWidthHeight.rawValue, height: Dimensions.arrowWidthHeight.rawValue)
                            .foregroundColor(color)
                            .rotationEffect(Angle(degrees: 90))
                    } else {
                        Arrow()
                            .frame(width: Dimensions.arrowWidthHeight.rawValue, height: Dimensions.arrowWidthHeight.rawValue)
                            .foregroundColor(color)
                    }
                    FileIconView()
                        .padding(Dimensions.rowPadding.rawValue)
                    Text(title)
                        .bold()
                        .padding(Dimensions.rowPadding.rawValue)
                }
                
                .padding(Dimensions.rowPadding.rawValue)
  
            }
            .onTapGesture {
                toggle = !toggle
            }
        }
        
        
        if toggle {
            VStack(alignment: .leading) {
                ForEach(documents) { title in
                    if title.selected {
                        if colorScheme == .dark {
                            self.innerCell(title: title)
                                .overlay {
                                    Rectangle()
                                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 0.1))
                                        .cornerRadius(4)
                                }
                                
                                
                                .onTapGesture {
                                    treeViewModel.closure(self.id, title.id)
                                }
                        } else {
                            self.innerCell(title: title)
                                .overlay {
                                    Rectangle()
                                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.1))
                                        .cornerRadius(4)
                                }
                                .onTapGesture {
                                    treeViewModel.closure(self.id, title.id)
                                }
                        }
                        
                    } else {
                        self.innerCell(title: title)
                            .onTapGesture {
                                treeViewModel.closure(self.id, title.id)
                            }
                    }
                }
            }
            .padding([.leading], 40)
        }

    }
}

struct TreeViewItem_Previews: PreviewProvider {
    static var previews: some View {
        TreeViewItem(id: "123", title: "Testing title", documents: [Title(id: "123", value: "Title 1", selected: false), Title(id: "321", value: "Title 2", selected: true)])
    }
}
