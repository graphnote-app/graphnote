//
//  LabelContextMenu.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/21/23.
//

import SwiftUI

struct LabelContextMenu: View {
    let rename: () -> Void
    let delete: () -> Void
    
    var body: some View {
        Group {
            Menu("Set Color") {
                Button("Blue") {
                    
                }
                Button("Pink") {
                    
                }
                Button("Dark Orange") {
                    
                }
                Button("Lite Orange") {
                    
                }
                Button("Purple") {
                    
                }
                Button("Yellow") {
                    
                }
            }
            Button("Rename") {
                rename()
            }
            Button("Drop") {
                delete()
            }
        }
    }
}

struct LabelContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        LabelContextMenu {
            
        } delete: {
            
        }

    }
}
