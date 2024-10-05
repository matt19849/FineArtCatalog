//
//  FineArtCatalogApp.swift
//  FineArtCatalog
//
//  Created by Matt Cooper on 5/10/2024.
//

import SwiftUI

@main
struct FineArtCatalogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
