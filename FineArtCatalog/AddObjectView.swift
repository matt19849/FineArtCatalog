import SwiftUI
import CoreData
import PhotosUI

struct AddObjectView: View {
    // Access the managed object context
    @Environment(\.managedObjectContext) private var viewContext
    // Environment to dismiss the view
    @Environment(\.presentationMode) var presentationMode

    // The collection to which the object will be added
    var collection: Collection?

    // State variables
    @State private var selectedObjectType: String = "Artwork"
    @State private var showArtworkFields: Bool = true
    @State private var storageType: String = "Climate"
    @State private var storageLocation: String = ""
    @State private var artworkMedium: String = "Painting"
    @State private var artworkTitle: String = ""
    @State private var artistName: String = ""
    @State private var date: Date = Date()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet: Bool = false
    @State private var cartonContents: String = "" // Added @State variable
    

    // Alert State
    @State private var activeAlert: ActiveAlert?

    // Options
    let objectTypes = ["Artwork", "Furniture", "Crate", "Carton", "Package"]
    let storageTypes = ["Climate", "Not Climate"]
    @State private var artworkMediums: [String] = ["Painting", "Sculpture"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Display Client Name and Removal Number
                if let collection = collection {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Client: \(collection.clientName ?? "Unknown")")
                            .font(.headline)
                        Text("Removal Number: \(collection.removalNumber ?? "N/A")")
                            .font(.headline)
                    }
                }

                // Object Type Picker with Label
                VStack(alignment: .leading, spacing: 5) {
                    Text("Select Object Type")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Picker("Select Object Type", selection: $selectedObjectType) {
                        ForEach(objectTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedObjectType) { value in
                        showArtworkFields = (value == "Artwork")
                        // Update flags for other object types if necessary
                    }
                }

                // Conditional Fields Based on Object Type
                if selectedObjectType == "Artwork" {
                    ArtworkFieldsView(
                        storageType: $storageType,
                        storageLocation: $storageLocation,
                        artworkMedium: $artworkMedium,
                        artworkTitle: $artworkTitle,
                        artistName: $artistName,
                        date: $date,
                        selectedImage: $selectedImage,
                        showImagePicker: $showImagePicker,
                        showActionSheet: $showActionSheet,
                        artworkMediums: $artworkMediums,
                        imageSource: $imageSource // <-- Pass the binding here
                    )
                } else if selectedObjectType == "Carton" {
                    CartonFieldsView(
                        storageType: $storageType,
                        storageLocation: $storageLocation,
                        cartonContents: $cartonContents // Pass the binding
                    )
                }
                // Add other object type fields here as needed

                // Save Button
                Button(action: {
                    saveObject()
                }) {
                    Text("Save Object")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(5)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Add Object")
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

    // Function to add a new medium
    private func addNewMedium() { // ✅ Correct: Top-level function
        // Implement a way to input the new medium, such as presenting an alert with a TextField
        // For simplicity, appending a predefined value
        let newMedium = "New Medium"
        if !artworkMediums.contains(newMedium) {
            artworkMediums.append(newMedium)
            artworkMedium = newMedium
        }
    }

    // Function to save the object
    private func saveObject() {
        guard let collection = collection else {
            activeAlert = .error("No collection available to save the object.")
            return
        }

        let newObject: Object

        if selectedObjectType == "Artwork" {
            let artwork = Artwork(context: viewContext)
            artwork.storageType = storageType
            artwork.storageLocation = storageLocation
            artwork.medium = artworkMedium
            artwork.title = artworkTitle
            artwork.artistName = artistName
            artwork.date = date
            if let image = selectedImage {
                artwork.photo = image.jpegData(compressionQuality: 0.8)
            }
            newObject = artwork
        } else if selectedObjectType == "Carton" {
            let carton = Carton(context: viewContext)
            carton.storageType = storageType
            carton.storageLocation = storageLocation
            carton.contents = cartonContents // Use cartonContents
            newObject = carton
        } else {
            // Handle other object types similarly
            let object = Object(context: viewContext)
            object.storageType = selectedObjectType
            // Add other attributes as needed based on object type
            newObject = object
        }

        newObject.collection = collection

        do {
            try viewContext.save()
            // Show success alert
            activeAlert = .success
        } catch {
            // Capture and show error message
            let nsError = error as NSError
            activeAlert = .error(nsError.localizedDescription)
            print("Error saving object: \(error)")
        }
    }
}

// CartonFieldsView accepting bindings
struct CartonFieldsView: View {
    @Binding var storageType: String
    @Binding var storageLocation: String
    @Binding var cartonContents: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Storage Type Picker
            VStack(alignment: .leading, spacing: 5) {
                Text("Storage Type")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Picker("Storage Type", selection: $storageType) {
                    ForEach(["Climate", "Not Climate"], id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            // Storage Location Field
            VStack(alignment: .leading, spacing: 5) {
                Text("Storage Location")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter storage location", text: $storageLocation)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
            }

            // Carton Contents Field
            VStack(alignment: .leading, spacing: 5) {
                Text("Contents")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter contents", text: $cartonContents)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
            }
        }
    }
}

struct AddObjectView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleCollection = Collection(context: context)
        sampleCollection.clientName = "Sample Client"
        sampleCollection.removalNumber = "001"
        sampleCollection.timestamp = Date()

        return NavigationView {
            AddObjectView(collection: sampleCollection)
                .environment(\.managedObjectContext, context)
        }
    }
}

// Example of ArtworkFieldsView
struct ArtworkFieldsView: View {
    @Binding var storageType: String
    @Binding var storageLocation: String
    @Binding var artworkMedium: String
    @Binding var artworkTitle: String
    @Binding var artistName: String
    @Binding var date: Date
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    @Binding var showActionSheet: Bool
    @Binding var artworkMediums: [String]
    @Binding var imageSource: UIImagePickerController.SourceType // <-- Added Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Storage Type Picker
            VStack(alignment: .leading, spacing: 5) {
                Text("Storage Type")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Picker("Storage Type", selection: $storageType) {
                    ForEach(["Climate", "Not Climate"], id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            // Storage Location Field
            VStack(alignment: .leading, spacing: 5) {
                Text("Storage Location")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter storage location", text: $storageLocation)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
            }

            // Artwork Medium Picker with Add Option
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Artwork Medium")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        addNewMedium(artworkMediums: $artworkMediums, artworkMedium: $artworkMedium) // Pass the bindings
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Add New Medium")
                }
                
                Picker("Artwork Medium", selection: $artworkMedium) {
                    ForEach(artworkMediums, id: \.self) { medium in
                        Text(medium).tag(medium)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            // Artwork Title Field
            VStack(alignment: .leading, spacing: 5) {
                Text("Artwork Title")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter artwork title", text: $artworkTitle)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
            }

            // Artist Name Field
            VStack(alignment: .leading, spacing: 5) {
                Text("Artist Name")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter artist name", text: $artistName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
            }

            // Date Picker
            VStack(alignment: .leading, spacing: 5) {
                Text("Date")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                DatePicker("Select date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }

            // Photo Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Photo")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showActionSheet = true
                }) {
                    Text(selectedImage == nil ? "Select Photo" : "Change Photo")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("Select Photo"), message: nil, buttons: [
                        .default(Text("Photo Library")) {
                            imageSource = .photoLibrary
                            showImagePicker = true
                        },
                        .default(Text("Take Photo")) {
                            imageSource = .camera
                            showImagePicker = true
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(sourceType: imageSource, selectedImage: $selectedImage)
                }
            }
        }

        
    }
}
// Function to add a new medium
func addNewMedium(artworkMediums: Binding<[String]>, artworkMedium: Binding<String>) { // Pass the bindings
    let newMedium = "New Medium"
    if !artworkMediums.wrappedValue.contains(newMedium) {
        artworkMediums.wrappedValue.append(newMedium)
        artworkMedium.wrappedValue = newMedium
    }
}
