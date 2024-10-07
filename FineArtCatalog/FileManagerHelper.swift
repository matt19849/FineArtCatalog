import UIKit

class FileManagerHelper {
    static let shared = FileManagerHelper()
    let fileManager = FileManager.default
    let photosDirectory: URL

    private init() {
        // Define the directory to store photos
        photosDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Photos")
        
        // Create the directory if it doesn't exist
        if !fileManager.fileExists(atPath: photosDirectory.path) {
            do {
                try fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating photos directory: \(error)")
            }
        }
    }

    func saveImage(_ image: UIImage) throws -> String {
        // Generate a unique filename
        let filename = UUID().uuidString + ".png"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        // Convert UIImage to Data
        guard let data = image.pngData() else {
            throw NSError(domain: "FileManagerHelper", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to PNG data"])
        }
        
        // Write data to file
        try data.write(to: fileURL)
        
        return filename // Return the filename to store in Core Data
    }

    func loadImage(named filename: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }

    func deleteImage(named filename: String) {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                print("Error deleting image: \(error)")
            }
        }
    }
}
