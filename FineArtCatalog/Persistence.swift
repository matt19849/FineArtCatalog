import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FineArtCatalog")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        // Attempt to load persistent store
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Enhanced error handling with logging
                print("Unresolved error while loading persistent store: \(error), \(error.userInfo)")
                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                    print("Underlying error: \(underlyingError), \(underlyingError.userInfo)")
                }

                // Check for specific migration error
                if error.code == NSPersistentStoreIncompatibleVersionHashError || error.code == NSPersistentStoreIncompatibleSchemaError {
                    print("Migration issue encountered. Data model may have changed without proper migration.")
                }

                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Persistent store loaded successfully: \(storeDescription)")
            }
        }
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Optionally create sample data for previews
        return result
    }()
}
