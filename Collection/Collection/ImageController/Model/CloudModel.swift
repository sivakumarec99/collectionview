//
//  CloudModel.swift
//  Collection
//
//  Created by JIDTP1408 on 25/02/25.
//
import UIKit
import Foundation
import FirebaseCore
import FirebaseStorage

class CloudService {
    
    static let storage = Storage.storage().reference()

    /// Uploads an image to Firebase Storage and returns the download URL
      static func uploadImageCloud(_ image: UIImage, completion: @escaping (String?) -> Void) {
          guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
          
          let fileName = UUID().uuidString
          let imageRef = storage.child("images/\(fileName).jpg")
          
          imageRef.putData(imageData, metadata: nil) { _, error in
              if let error = error {
                  print("Upload failed: \(error.localizedDescription)")
                  completion(nil)
                  return
              }
              
              imageRef.downloadURL { url, _ in
                  completion(url?.absoluteString)
              }
          }
      }
    
    static func fetchImagesClould(completion: @escaping ([String]) -> Void) {
        let imagesRef = storage.child("images")
        
        imagesRef.listAll { (result, error) in
            if let error = error {
                print("Error fetching images: \(error)")
                completion([])
                return
            }
            
            var urls: [String] = []
            let dispatchGroup = DispatchGroup()
            
            for item in result!.items {
                dispatchGroup.enter()
                item.downloadURL { url, _ in
                    if let url = url {
                        urls.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(urls)
            }
        }
    }
    
    static func deleteImageFromFirebase(_ imageUrl: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: imageUrl) else {
            completion(false)
            return
        }
        
        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
        
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Image deleted successfully")
                completion(true)
            }
        }
    }
    
    
    
    // URL API Image Fetch
    
    static func fetchImages(completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "https://your-cloud-api.com/images") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let imageUrls = try JSONDecoder().decode([String].self, from: data)
                    completion(imageUrls)
                } catch {
                    print("Failed to decode: \(error)")
                }
            }
        }.resume()
    }
    
  
    // URL API  Image Upload
    static func uploadImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
            let url = URL(string: "https://your-cloud-api.com/upload")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

            let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
                if let error = error {
                    print("Upload failed: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
            task.resume()
        }
    

}
