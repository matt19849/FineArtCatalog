import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Called when the user has selected some photos
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let imageLoadingGroup = DispatchGroup()

            // Loop through selected results
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    imageLoadingGroup.enter() // Start tracking loading progress
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                        imageLoadingGroup.leave() // Done loading this image
                    }
                }
            }

            // Ensure the images are updated only when all are processed
            imageLoadingGroup.notify(queue: .main) {
                // Optionally handle anything when all images are loaded
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5 - selectedImages.count // Limit selection to max of 5
        config.filter = .images // Only allow images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No need to update the picker once it's presented
    }
}
