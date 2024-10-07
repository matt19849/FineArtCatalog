import SwiftUI
import CoreData

struct AddObjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var collection: Collection?

    // State for multiple photos
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker: Bool = false
    @State private var showCameraPicker: Bool = false
    @State private var activeAlert: ActiveAlert?
    @State private var showActionSheet: Bool = false

    // States for various object types
    @State private var artworkTitle: String = ""
    @State private var artistName: String = ""
    @State private var furnitureDescription: String = ""
    @State private var crateDimensions: String = ""
    @State private var crateContents: String = ""
    @State private var cartonDimensions: String = ""
    @State private var cartonContents: String = ""
    @State private var packageDimensions: String = ""
    @State private var packageContents: String = ""
    @State private var storageType: String = "Climate"
    @State private var storageLocation: String = ""
    @State private var artworkMedium: String = "Painting"
    @State private var date: Date = Date()

    // Object type selection
    @State private var selectedObjectType: String = "Artwork"
    let objectTypes = ["Artwork", "Furniture", "Crate", "Carton", "Package"]
    let storageTypes = ["Climate", "Not Climate"]
    let artworkMediums = ["Painting", "Sculpture"]

    // Binding for captured image
    @State private var capturedImage: UIImage? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Object type picker
                Text("Select Object Type")
                    .font(.headline)
                Picker("Object Type", selection: $selectedObjectType) {
                    ForEach(objectTypes, id: \.self) { type in
                        Text(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                // Show relevant fields based on selected object type
                if selectedObjectType == "Artwork" {
                    artworkFields
                } else if selectedObjectType == "Furniture" {
                    furnitureFields
                } else if selectedObjectType == "Crate" {
                    crateFields
                } else if selectedObjectType == "Carton" {
                    cartonFields
                } else if selectedObjectType == "Package" {
                    packageFields
                }

                // Photo selection section (common to all objects)
                photoSelectionSection

                // Save button
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
            }
            .padding()
        }
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
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Add Photo"), message: Text("Choose a photo source"), buttons: [
                .default(Text("Photo Library")) {
                    showImagePicker = true
                },
                .default(Text("Camera")) {
                    // Check if camera is available
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showCameraPicker = true
                    } else {
                        activeAlert = .error("Camera is not available on this device.")
                    }
                },
                .cancel()
            ])
        }
        // Sheet for Photo Library Picker
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
                .onDisappear {
                    // Handle any additional actions after picking images
                }
        }
        // Sheet for Camera Picker
        .sheet(isPresented: $showCameraPicker) {
            CameraPicker(capturedImage: $capturedImage)
                .onDisappear {
                    if let image = capturedImage {
                        addImage(image)
                        capturedImage = nil // Reset capturedImage to prevent duplication
                    }
                }
        }
    }

    // Artwork fields
    private var artworkFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Artwork Title")
                .font(.subheadline)
            TextField("Enter artwork title", text: $artworkTitle)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            Text("Artist Name")
                .font(.subheadline)
            TextField("Enter artist name", text: $artistName)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            commonFields
        }
    }

    // Furniture fields
    private var furnitureFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Furniture Description")
                .font(.subheadline)
            TextField("Enter furniture description", text: $furnitureDescription)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            commonFields
        }
    }

    // Crate fields
    private var crateFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Crate Dimensions")
                .font(.subheadline)
            TextField("Enter crate dimensions", text: $crateDimensions)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            Text("Crate Contents")
                .font(.subheadline)
            TextField("Enter crate contents", text: $crateContents)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            commonFields
        }
    }

    // Carton fields
    private var cartonFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Carton Dimensions")
                .font(.subheadline)
            TextField("Enter carton dimensions", text: $cartonDimensions)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            Text("Carton Contents")
                .font(.subheadline)
            TextField("Enter carton contents", text: $cartonContents)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            commonFields
        }
    }

    // Package fields
    private var packageFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Package Dimensions")
                .font(.subheadline)
            TextField("Enter package dimensions", text: $packageDimensions)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            Text("Package Contents")
                .font(.subheadline)
            TextField("Enter package contents", text: $packageContents)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            commonFields
        }
    }

    // Common fields for all objects
    private var commonFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Storage Type")
                .font(.subheadline)
            Picker("Storage Type", selection: $storageType) {
                ForEach(storageTypes, id: \.self) { type in
                    Text(type)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Text("Storage Location")
                .font(.subheadline)
            TextField("Enter storage location", text: $storageLocation)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)

            Text("Date")
                .font(.subheadline)
            DatePicker("Select date", selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
        }
    }

    // Photo selection section (common to all objects)
    private var photoSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Photos")
                .font(.subheadline)
                .foregroundColor(.gray)

            if selectedImages.isEmpty {
                Text("No photos selected.")
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(10)
                        }
                    }
                }
            }

            Button(action: {
                if selectedImages.count < 5 {
                    showActionSheet = true
                } else {
                    activeAlert = .error("You can only select up to 5 photos.")
                }
            }) {
                Text(selectedImages.isEmpty ? "Add Photos" : "Add More Photos")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(5)
            }
        }
    }
    
    // Function to add a captured image to the selectedImages array
    private func addImage(_ image: UIImage) {
        if selectedImages.count < 5 {
            selectedImages.append(image)
        } else {
            activeAlert = .error("You can only select up to 5 photos.")
        }
    }

    private func saveObject() {
        guard let collection = collection else {
            activeAlert = .error("No collection available to save the object.")
            return
        }

        let newObject: CatalogObject // Updated Class

        // Create the new object based on the selected type
        if selectedObjectType == "Artwork" {
            let artwork = Artwork(context: viewContext)
            artwork.title = artworkTitle
            artwork.artistName = artistName
            artwork.storageType = storageType
            artwork.storageLocation = storageLocation
            artwork.medium = artworkMedium
            artwork.date = date
            artwork.objectType = "Artwork"
            newObject = artwork
            print("Created new Artwork object")
        } else if selectedObjectType == "Carton" {
            let carton = Carton(context: viewContext)
            carton.storageType = storageType
            carton.storageLocation = storageLocation
            carton.contents = cartonContents
            carton.objectType = "Carton"
            newObject = carton
            print("Created new Carton object")
        } else if selectedObjectType == "Crate" {
            let crate = Crate(context: viewContext)
            crate.storageType = storageType
            crate.storageLocation = storageLocation
            crate.contents = crateContents
            crate.objectType = "Crate"
            newObject = crate
            print("Created new Crate object")
        } else if selectedObjectType == "Furniture" {
            let furniture = Furniture(context: viewContext)
            furniture.storageType = storageType
            furniture.storageLocation = storageLocation
            furniture.furnitureDesc = furnitureDescription
            furniture.objectType = "Furniture"
            newObject = furniture
            print("Created new Furniture object")
        } else if selectedObjectType == "Package" {
            let package = Package(context: viewContext)
            package.storageType = storageType
            package.storageLocation = storageLocation
            package.contents = packageContents
            package.objectType = "Package"
            newObject = package
            print("Created new Package object")
        } else {
            activeAlert = .error("Unknown object type.")
            return
        }

        // Print all the values being passed to Core Data for this object
        print("Object Type: \(newObject.objectType)")
        print("Storage Type: \(newObject.storageType ?? "nil")")
        print("Storage Location: \(newObject.storageLocation ?? "nil")")
        print("Date: \(newObject.date ?? Date())")
        
        if let artwork = newObject as? Artwork {
            print("Artwork Title: \(artwork.title ?? "nil")")
            print("Artist Name: \(artwork.artistName ?? "nil")")
            print("Medium: \(artwork.medium ?? "nil")")
        } else if let carton = newObject as? Carton {
            print("Carton Dimensions: \(carton.dimensions ?? "nil")")
            print("Carton Contents: \(carton.contents ?? "nil")")
        } else if let crate = newObject as? Crate {
            print("Crate Dimensions: \(crate.dimensions ?? "nil")")
            print("Crate Contents: \(crate.contents ?? "nil")")
        } else if let furniture = newObject as? Furniture {
            print("Furniture Description: \(furniture.furnitureDesc ?? "nil")")
        } else if let package = newObject as? Package {
            print("Package Dimensions: \(package.dimensions ?? "nil")")
            print("Package Contents: \(package.contents ?? "nil")")
        }

        // Set the collection relationship
        newObject.collection = collection
        print("Set collection relationship to the new object")

        // Save photos independently of the object
        do {
            print("Before processing images, newObject is fault: \(newObject.isFault)")
            var savedPhotos: [ObjectPhoto] = []

            for (index, image) in selectedImages.enumerated() {
                print("Processing image \(index + 1)")
                // Resize image if necessary
                let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 800, height: 800))
                
                let filename = try FileManagerHelper.shared.saveImage(resizedImage)
                print("Saved image \(index + 1) to file system with filename: \(filename)")
                
                // Create a new ObjectPhoto for each image
                let photo = ObjectPhoto(context: viewContext)
                photo.photoPath = filename
                print("Created ObjectPhoto for image \(index + 1) with path: \(filename)")

                savedPhotos.append(photo)
            }

            // Save the context to persist ObjectPhotos
            print("Attempting to save Core Data with all photos (without linking to object yet)")
            try viewContext.save()  // First save
            print("Successfully saved photos, now linking to the object")

            // Link the saved photos to the object
            for (index, photo) in savedPhotos.enumerated() {
                print("Linking photo \(index + 1) to newObject")
                
                // Add the photo to the newObject's photos set
                newObject.addToPhotos(photo)

                print("Photo \(index + 1) successfully linked to newObject")
            }

            // Final save after linking all photos to the object
            print("Final save after linking all photos to the object")
            try viewContext.save()

            activeAlert = .success

        } catch let error as NSError {
            print("Core Data error during save: \(error), \(error.userInfo)")
            activeAlert = .error("Failed to save object: \(error.localizedDescription)")
        }
    }

    // Function to resize images before saving them to file system
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Determine the scaling factor
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // Draw the image with the target size
        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

struct AddObjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddObjectView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
