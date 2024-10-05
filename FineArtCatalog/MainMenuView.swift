import SwiftUI
import CoreData

struct MainMenuView: View {
    // State to present AddCollectionView
    @State private var showAddCollectionView: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                NavigationLink(destination: CollectionListView()) {
                    Text("View Existing Collections")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(5)
                }


                // Button to present AddCollectionView
                Button(action: {
                    showAddCollectionView = true
                }) {
                    Text("Add New Collection")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(5)
                }
                .sheet(isPresented: $showAddCollectionView) {
                    AddCollectionView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Main Menu")
        }
    }

    struct MainMenuView_Previews: PreviewProvider {
        static var previews: some View {
            MainMenuView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
