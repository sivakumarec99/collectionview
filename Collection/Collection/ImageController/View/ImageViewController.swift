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
    private let refreshControl = UIRefreshControl()
    var selectedImages = Set<Int>() // Store selected image indexes
    var isSelecting = false  // Track if selection mode is active
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
        self.view.backgroundColor = .black
        collectionView.backgroundColor = .clear
        // Add the upload button
        uploadButton.frame = CGRect(x: 20, y: view.bounds.height - 80, width: view.bounds.width - 40, height: 50)
        uploadButton.backgroundColor = .systemBlue
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.layer.cornerRadius = 10
        view.addSubview(uploadButton)
        
        uploadButton.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)
        fetchImagesFromCloud()
        
        // Add Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshImages), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        
        // Enable user interaction
              
        collectionView.isUserInteractionEnabled = true
        collectionView.dragInteractionEnabled = true // Enable drag interaction
        // Add Swipe Gesture Recognizer
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .left
        collectionView.addGestureRecognizer(swipeGesture)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 10
        let itemWidth = (view.frame.width / 2) - (padding * 1.5)

        layout.itemSize = CGSize(width: itemWidth, height: 200)
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)

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
    @objc private func refreshImages() {
        fetchImagesFromCloud()
    }
    
    @objc private func uploadImageTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func fetchImagesFromCloud() {
        activityIndicator.startAnimating()
        CloudService.fetchImagesClould { [weak self] urls in
            DispatchQueue.main.async {
                self?.imageUrls = urls
                self?.collectionView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()

            }
        }
    }
    
    private func uploadImageToCloud(_ image: UIImage) {
        activityIndicator.startAnimating()
        
        CloudService.uploadImageCloud(image) { url in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if (url != nil) {
                    print("Image uploaded successfully!")
                    self.fetchImagesFromCloud() // Refresh images
                } else {
                    print("Image upload failed.")
                }
            }
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
           let location = gesture.location(in: collectionView)
           
           if let indexPath = collectionView.indexPathForItem(at: location) {
               let imageUrl = imageUrls[indexPath.row]
               
               CloudService.deleteImageFromFirebase(imageUrl) { success in
                   if success {
                       DispatchQueue.main.async {
                           self.imageUrls.remove(at: indexPath.row)
                           self.collectionView.deleteItems(at: [indexPath])
                       }
                   }
               }
           }
       }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        let location = gesture.location(in: collectionView)
//            guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
//            
//            switch gesture.state {
//            case .began:
//                collectionView.beginInteractiveMovementForItem(at: indexPath)
//            case .changed:
//                collectionView.updateInteractiveMovementTargetPosition(location)
//            case .ended:
//                collectionView.endInteractiveMovement()
//            default:
//                collectionView.cancelInteractiveMovement()
//            }
        if gesture.state == .began {
            isSelecting = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteSelectedImages))
        }
    }
    
    @objc func deleteSelectedImages() {
        let selectedIndexes = selectedImages.sorted(by: >)  // Delete in reverse order to avoid index shifting
        
        for index in selectedIndexes {
            let imageUrl = imageUrls[index]
            CloudService.deleteImageFromFirebase(imageUrl, completion: {done in
                self.imageUrls.remove(at: index)
                self.selectedImages.removeAll()
                self.isSelecting = false
                self.collectionView.reloadData()
            })  // Delete from Firebase Storage
        }
    }
    func openFullScreenImage(_ imageUrl: String) {
        let fullScreenVC = FullScreenImageViewController(imageUrl: imageUrl)
        fullScreenVC.modalPresentationStyle = .fullScreen
        present(fullScreenVC, animated: true)
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
        cell.configure(with: imageUrls[indexPath.item], isSelected: isSelecting)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelecting {
            if selectedImages.contains(indexPath.row) {
                selectedImages.remove(indexPath.row)
            } else {
                selectedImages.insert(indexPath.row)
            }
            collectionView.reloadItems(at: [indexPath]) // Update UI
        } else {
            // Open image fullscreen if not selecting
            let imageUrl = imageUrls[indexPath.row]
            openFullScreenImage(imageUrl)
        }
    }
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        true
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
           cell.alpha = 0
           cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)  // Start smaller

           UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row), options: .curveEaseInOut) {
               cell.alpha = 1
               cell.transform = .identity  // Restore to normal size
           }
       }
    
}

extension ImageViewController :UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let padding: CGFloat = 10
           let itemsPerRow: CGFloat = 2  // Adjust if you want 3 columns
           let totalSpacing = (itemsPerRow + 1) * padding  // Total spacing between items and edges
           
           let itemWidth = (collectionView.frame.width - totalSpacing) / itemsPerRow
           return CGSize(width: itemWidth, height: itemWidth) // Square cells
       }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//           let padding: CGFloat = 10
//           let itemsPerRow: CGFloat = 2
//           let totalSpacing = (itemsPerRow + 1) * padding
//           let itemWidth = (collectionView.frame.width - totalSpacing) / itemsPerRow
//           
//           // Get image aspect ratio (Use a placeholder if not loaded yet)
//           let image = imageUrls[indexPath.row]  // Your image model We Need to get image Size
//           let aspectRatio = image.size.height / image.size.width  // Calculate aspect ratio
//           
//           let itemHeight = itemWidth * aspectRatio  // Adjust height based on aspect ratio
//           return CGSize(width: itemWidth, height: itemHeight)
//       }
}

extension ImageViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = imageUrls[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}
extension ImageViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates {
                    let movedItem = imageUrls.remove(at: sourceIndexPath.row)
                    imageUrls.insert(movedItem, at: destinationIndexPath.row)
                    collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                }
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true // Allow all drops
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}
