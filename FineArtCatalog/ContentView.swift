import SwiftUI

struct ContentView: View {
    var body: some View {
        MainMenuView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
