//
//  ImageCollectionViewCell.swift
//  Collection
//
//  Created by JIDTP1408 on 24/02/25.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell:  UICollectionViewCell {
    static let identifier = "ImageCell"
    
    private let shimmerView = ShimmerView()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let overlayView: UIView = {
          let view = UIView()
          view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
          view.isHidden = true  // Hide by default
          view.translatesAutoresizingMaskIntoConstraints = false
          view.layer.cornerRadius = 8
          return view
      }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(shimmerView)
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
      
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)

        
        shimmerView.frame = contentView.bounds
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with imageUrl: String, isSelected: Bool) {
        shimmerView.isHidden = false
        imageView.image = nil

        imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholder"), options: [.continueInBackground, .progressiveLoad])
        
        overlayView.isHidden = !isSelected  // Show overlay when selected

//        DispatchQueue.global().async {
//            if let url = URL(string: imageUrl), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.imageView.image = image
//                    self.shimmerView.isHidden = true
//                    self.imageView.alpha = 0
//                    UIView.animate(withDuration: 0.5) {
//                        self.imageView.alpha = 1
//                    }
//                }
//            }
//        }
    }
}
