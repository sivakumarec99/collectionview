//
//  ImageViewController.swift
//  Collection
//
//  Created by JIDTP1408 on 24/02/25.
//
import UIKit

class ImageViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var imageUrls: [String] = [] // Store image URLs from cloud

    //UI
    private let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Image", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchImagesFromCloud() // Fetch images on load
        
        // Add the upload button
          uploadButton.frame = CGRect(x: 20, y: view.bounds.height - 80, width: view.bounds.width - 40, height: 50)
          uploadButton.backgroundColor = .systemBlue
          uploadButton.setTitleColor(.white, for: .normal)
          uploadButton.layer.cornerRadius = 10
          view.addSubview(uploadButton)
        uploadButton.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)

        
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100) // Adjust as needed
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        //Loading..
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
    }

    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
}

extension ImageViewController {
    //action
    
    @objc private func uploadImageTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    private func fetchImagesFromCloud() {
        activityIndicator.startAnimating()
        
        CloudService.fetchImages { [weak self] urls in
            DispatchQueue.main.async {
                self?.imageUrls = urls
                self?.collectionView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func uploadImageToCloud(_ image: UIImage) {
        activityIndicator.startAnimating()
        
        CloudService.uploadImage(image) { success in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if success {
                    print("Image uploaded successfully!")
                    self.fetchImagesFromCloud() // Refresh images
                } else {
                    print("Image upload failed.")
                }
            }
        }
    }
    
}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            uploadImageToCloud(selectedImage)
        }
    }
}

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        cell.configure(with: imageUrls[indexPath.item])
        return cell
    }
}

class CloudService {
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

