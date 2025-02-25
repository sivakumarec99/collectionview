//
//  FullScreenImageViewController.swift
//  Collection
//
//  Created by JIDTP1408 on 25/02/25.
//

import UIKit
import SDWebImage

class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {
    private let imageUrl: String

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    init(imageUrl: String) {
        self.imageUrl = imageUrl
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        scrollView.frame = view.bounds
        imageView.frame = scrollView.bounds

        imageView.sd_setImage(with: URL(string: imageUrl))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeFullscreen))
        view.addGestureRecognizer(tapGesture)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    @objc private func closeFullscreen() {
        dismiss(animated: true)
    }
}
