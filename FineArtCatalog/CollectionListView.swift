import SwiftUI
import CoreData

struct CollectionListView: View {
    // Access the managed object context
    @Environment(\.managedObjectContext) private var viewContext

    // FetchRequest to retrieve collections, sorted by timestamp descending
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Collection.timestamp, ascending: false)],
        animation: .default)
    private var collections: FetchedResults<Collection>

    // State to control the presentation of AddCollectionView
    @State private var showAddCollectionView: Bool = false

    var body: some View {
        List {
            ForEach(collections, id: \.self) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                    VStack(alignment: .leading) {
                        Text(collection.clientName ?? "Unknown Client")
                            .font(.headline)
                        Text("Removal #: \(collection.removalNumber ?? "N/A")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteCollections)
        }
        .navigationTitle("Collections")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddCollectionView = true
                }) {
                    Label("Add Collection", systemImage: "plus")
                }
                .sheet(isPresented: $showAddCollectionView) {
                    AddCollectionView()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
    }

    // Function to delete collections from Core Data
    private func deleteCollections(offsets: IndexSet) {
        withAnimation {
            offsets.map { collections[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the app to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                // Optionally, present an alert to the user
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct CollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return NavigationView {
            CollectionListView()
                .environment(\.managedObjectContext, context)
        }
    }
}
