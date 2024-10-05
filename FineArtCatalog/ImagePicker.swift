import SwiftUI
import CoreData
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    // Source type: photo library or camera
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    // Binding to the selected image
    @Binding var selectedImage: UIImage?

    // Coordinator to handle image picking
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Image was picked
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }

            picker.dismiss(animated: true)
        }

        // Picker was cancelled
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    // Create the coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Create the UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    // No need to update the controller
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
