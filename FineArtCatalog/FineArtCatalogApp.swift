import SwiftUI

@main
struct FineArtCatalogApp: App {
    // Initialize the PersistenceController
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


