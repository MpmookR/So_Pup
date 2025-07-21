// cloud: Image/file uploads/downloads
// focused on Firebase Storage (bucket files, images, uploads/downloads)
import Foundation
import FirebaseStorage
import UIKit

enum FirebaseStorageError: Error {
    case invalidImageData
    case uploadFailed(String)
}

class FirebaseMediaService {
    static let shared = FirebaseMediaService()
    private init() {}
   
    /// https://firebase.google.com/docs/storage/ios/upload-files?
    /// Uploads a UIImage to Firebase Storage and returns its download URL
        /// - Parameters:
        ///   - image: The UIImage to upload
        ///   - path: The full path in the bucket (e.g., "users/{uid}/profile.jpg")
        /// - Returns: A public download URL string for the uploaded image
        func uploadImage(_ image: UIImage?, path: String) async throws -> String {
            // Validate the image and convert to JPEG data
            guard let image = image,
                  let data = image.jpegData(compressionQuality: 0.8) else {
                throw FirebaseStorageError.invalidImageData
            }

            // Create a reference directly to the desired file location in Firebase Storage
            let fileRef = Storage.storage().reference().child(path)

            // Set metadata to specify content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            do {
                // Upload the image data asynchronously
                _ = try await fileRef.putDataAsync(data, metadata: metadata)

                // Retrieve and return the download URL
                let downloadURL = try await fileRef.downloadURL()
                print("✅ Image uploaded to path: \(path)")
                return downloadURL.absoluteString
            } catch {
                // Handle upload or URL retrieval failures
                print("❌ Upload failed at path: \(path)")
                print("   Error: \(error.localizedDescription)")
                throw FirebaseStorageError.uploadFailed(error.localizedDescription)
            }
    }
    
    /// Uploads multiple images to Firebase Storage and returns their download URLs
    /// - Parameters:
    ///   - images: Array of UIImage
    ///   - pathPrefix: Folder path (e.g. "dogs/{uid}/")
    ///   - limit: Optional max number of images (default = all)
    /// - Returns: Array of download URL strings
    func uploadImages(_ images: [UIImage], pathPrefix: String, limit: Int? = nil) async throws -> [String] {
        var urls: [String] = []

        for (index, image) in images.prefix(limit ?? images.count).enumerated() {
            let path = "\(pathPrefix)\(index).jpg"
            let url = try await uploadImage(image, path: path)
            urls.append(url)
        }

        return urls
    }


    func deleteImage(atPath path: String) async throws {
        let ref = Storage.storage().reference().child(path)
        try await ref.delete()
        print("🗑️ Deleted image at: \(path)")
    }
}
