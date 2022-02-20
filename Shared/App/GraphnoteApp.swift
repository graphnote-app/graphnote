//
//  GraphnoteApp.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import CoreData
import SwiftUI

fileprivate enum MacOSDimensions: CGFloat {
    case windowMinWidth = 1038
    case windowMinHeight = 600
}

extension Sequence {
    func find(_ isIncluded: (Element) throws -> Bool) rethrows -> Element? {
        do {
            return try self.filter(isIncluded).first
        } catch {
            return nil
        }
    }
}

let reseed = false

@main
struct GraphnoteApp: App {
    @StateObject private var dataController = DataController.shared
    
    private func fetchInitialDocument() -> (UUID, UUID)? {
        let fetchRequest: NSFetchRequest<Workspace>
        fetchRequest = Workspace.fetchRequest()
        do {
            let workspaces = try dataController.container.viewContext.fetch(fetchRequest)
            
            guard let workspace = workspaces.first else {
                return nil
            }
            
            let docsFetchRequest: NSFetchRequest<Document>
            docsFetchRequest = Document.fetchRequest()
//            docsFetchRequest.predicate = NSPredicate(format: "workspace.id == %@", workspace.id.uuidString)
            
            let documents = try dataController.container.viewContext.fetch(docsFetchRequest)
            
            guard let document = documents.first else {
                return nil
            }
            
            return (workspace.id, document.id)
            
        } catch {
            return nil
        }
    }
    
    func content() -> some View {
        #if os(macOS)
        GeometryReader { geometry in
            if let initialSelected = fetchInitialDocument() {
                ContentView(moc: dataController.container.viewContext, initialSelectedDocument: initialSelected.1, initalSelectedWorkspace: initialSelected.0)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(OrientationInfo())
                    .environmentObject(dataController)
            }
        }.frame(
            minWidth: MacOSDimensions.windowMinWidth.rawValue,
            idealWidth: MacOSDimensions.windowMinWidth.rawValue,
            minHeight: MacOSDimensions.windowMinHeight.rawValue,
            idealHeight: MacOSDimensions.windowMinHeight.rawValue
        )
            .task {
                
            }
        #else
        GeometryReader { geometry in
            if let initialSelected = fetchInitialDocument() {
                ContentView(moc: dataController.container.viewContext, initialSelectedDocument: initialSelected.1, initalSelectedWorkspace: initialSelected.0)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(OrientationInfo())
                    .environmentObject(dataController)
            }
        }
        #endif
    }
    
    var body: some Scene {
        #if os(macOS)
        WindowGroup() {
            content()
                .task {
                    if reseed {
                        dropDatabase()
                        seed()
                    }

                }
                
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
            
        #else
        WindowGroup {
            content()
                .task {
                    if reseed {
                        dropDatabase()
                        seed()
                    }
                }
        }
        #endif
    }
    
    func dropDatabase() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workspace.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! self.dataController.container.viewContext.execute(deleteRequest)
        
    }
    
    func seed() {
        let workspaceTitles = [
            "SwiftBook",
            "DarkTorch",
            "NSSWitch",
            "Kanception",
        ]

        let documentTitles = [
            "Design Doc",
            "Project Kickoff",
            "Technical Specification",
        ]

        let moc = self.dataController.container.viewContext
        
        for title in workspaceTitles {
            let workspace = Workspace(context: moc)
            let createdAt = Date.now
            workspace.createdAt = createdAt
            workspace.modifiedAt = createdAt
            workspace.id = UUID()
            workspace.title = title
            
            for docTitle in documentTitles {
                let document = Document(context: moc)
                document.id = UUID()
                let createdAt = Date.now
                document.createdAt = createdAt
                document.modifiedAt = createdAt
                document.title = docTitle
                document.workspace = workspace
            }
            
        }

        try! moc.save()
    }
}
