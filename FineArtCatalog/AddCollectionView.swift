import SwiftUI
import CoreData

struct AddCollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var clientName: String = ""
    @State private var removalNumber: String = ""

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    @State private var navigateToCollectionDetail: Bool = false
    @State private var newlyAddedCollection: Collection?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Client Information")) {
                    TextField("Client Name", text: $clientName)
                    TextField("Removal Number", text: $removalNumber)
                }

                Section {
                    Button(action: {
                        checkForDuplicateRemovalNumber()
                    }) {
                        Text("Save Collection")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(clientName.isEmpty || removalNumber.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(clientName.isEmpty || removalNumber.isEmpty)
                }
            }
            .navigationTitle("Add Collection")
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $navigateToCollectionDetail) {
                if let collection = newlyAddedCollection {
                    CollectionDetailView(collection: collection)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    // Function to check if a collection with the same removal number already exists
    private func checkForDuplicateRemovalNumber() {
        let fetchRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "removalNumber == %@", removalNumber)
        
        do {
            let matchingCollections = try viewContext.fetch(fetchRequest)
            if !matchingCollections.isEmpty {
                // A collection with this removal number already exists
                errorMessage = "A collection with this removal number already exists."
                showErrorAlert = true
            } else {
                // No duplicate, proceed with saving
                addCollection()
            }
        } catch {
            errorMessage = "Failed to check for duplicates: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    // Function to add a new collection
    private func addCollection() {
        let newCollection = Collection(context: viewContext)
        newCollection.clientName = clientName
        newCollection.removalNumber = removalNumber
        newCollection.timestamp = Date()

        do {
            try viewContext.save()
            // Set the newly added collection and trigger navigation
            newlyAddedCollection = newCollection
            navigateToCollectionDetail = true
        } catch {
            let nsError = error as NSError
            errorMessage = "Failed to save collection: \(nsError.localizedDescription)"
            showErrorAlert = true
        }
    }
}

struct AddCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddCollectionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
