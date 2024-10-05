import SwiftUI
import CoreData



struct CollectionDetailView: View {
    // Access the managed object context
    @Environment(\.managedObjectContext) private var viewContext
    // Environment to dismiss the view
    @Environment(\.presentationMode) var presentationMode

    // The collection to display details for
    var collection: Collection

    // FetchRequest to retrieve objects associated with the collection
    @FetchRequest var objects: FetchedResults<Object>

    // State to control the presentation of AddObjectView
    @State private var showAddObjectView: Bool = false

    // Alert State
    @State private var activeAlert: ActiveAlert?

    // Initializer to set up the FetchRequest with a predicate
    init(collection: Collection) {
        self.collection = collection
        let fetchRequest = NSFetchRequest<Object>(entityName: "Object") // <-- Ensure "Object" matches the entity name in your Core Data model
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Object.date, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "collection == %@", collection.objectID)
        
        _objects = FetchRequest(fetchRequest: fetchRequest, animation: .default)
    }



    var body: some View {
        VStack {
            if objects.isEmpty {
                Spacer()
                Text("No objects in this collection.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(objects, id: \.self) { object in
                        ObjectRowView(object: object)
                    }
                    .onDelete(perform: deleteObjects)
                }
                .listStyle(PlainListStyle())
            }

            Spacer()

            HStack {
                Button(action: {
                    showAddObjectView = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add More Objects")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }

                Button(action: {
                    saveAndClose()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Save and Close")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                }
            }
            .padding([.leading, .trailing, .bottom])
        }
        .navigationTitle("Collection Details")
        .sheet(isPresented: $showAddObjectView) {
            AddObjectView(collection: collection)
                .environment(\.managedObjectContext, viewContext)
            // Removed .environmentObject(authViewModel)
        }
        // Single Alert Modifier
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .success:
                return Alert(
                    title: Text("Success"),
                    message: Text("The object has been saved successfully."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            case .error(let message):
                return Alert(
                    title: Text("Error"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // Function to delete objects from the collection
    private func deleteObjects(offsets: IndexSet) {
        withAnimation {
            offsets.map { objects[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                activeAlert = .error("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // Function to save changes and dismiss the view
    private func saveAndClose() {
        do {
            try viewContext.save()
            activeAlert = .success
        } catch {
            let nsError = error as NSError
            activeAlert = .error("Failed to save changes: \(nsError.localizedDescription)")
            print("Error saving changes: \(error)")
        }
    }
}

// Subview to display individual objects
struct ObjectRowView: View {
    var object: Object

    var body: some View {
        HStack {
            if let imageData = object.photo, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(getTitle())
                    .font(.headline)
                Text(getSubtitle())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(getType())
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }

    // Helper functions to retrieve specific attributes based on the object type
    private func getTitle() -> String {
        if let artwork = object as? Artwork {
            return artwork.title ?? "Untitled Artwork"
        } else if let carton = object as? Carton {
            return "Carton"
        } else if let crate = object as? Crate {
            return "Crate"
        } else if let furniture = object as? Furniture {
            return furniture.furnitureDesc ?? "Furniture"
        } else if let package = object as? Package {
            return "Package"
        }
        return "Object"
    }

    private func getSubtitle() -> String {
        if let artwork = object as? Artwork {
            return "Artist: \(artwork.artistName ?? "Unknown")"
        } else if let carton = object as? Carton {
            return "Contents: \(carton.contents ?? "N/A")"
        } else if let crate = object as? Crate {
            return "Contents: \(crate.contents ?? "N/A")"
        } else if let furniture = object as? Furniture {
            return furniture.furnitureDesc ?? "N/A"
        } else if let package = object as? Package {
            return "Contents: \(package.contents ?? "N/A")"
        }
        return ""
    }

    private func getType() -> String {
        return object.object ?? "Unknown Type" // Consider renaming 'object' to 'objectType' in Core Data
    }
}

struct CollectionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample collection for preview
        let context = PersistenceController.preview.container.viewContext
        let sampleCollection = Collection(context: context)
        sampleCollection.clientName = "Sample Client"
        sampleCollection.removalNumber = "001"
        sampleCollection.timestamp = Date()

        return NavigationView {
            CollectionDetailView(collection: sampleCollection)
                .environment(\.managedObjectContext, context)
        }
    }
}
