//
//  ViewController.swift
//  Collection
//
//  Created by JIDTP1408 on 24/02/25.
//

import UIKit

class ViewController: UIViewController {

    private let navigateButton: UIButton = {
           let button = UIButton(type: .system)
           button.setTitle("Go to Second VC", for: .normal)
           return button
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
               setupButton()
        navigateButton.addTarget(self, action: #selector(navigateToSecondVC), for: .touchUpInside)

        
    }
    private func setupButton() {
           navigateButton.frame = CGRect(x: 50, y: 200, width: 200, height: 50)
           view.addSubview(navigateButton)
       }
       
       @objc private func navigateToSecondVC() {
           let secondVC = ImageViewController()
           navigationController?.pushViewController(secondVC, animated: true)
       }


}

