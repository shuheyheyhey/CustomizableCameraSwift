//
//  PreviewViewController.swift
//  CustomizableCameraSwift-Demo
//
//  Created by Shuhei Yukawa on 2023/08/04.
//

import Foundation
import UIKit

final class PreviewViewController: UIViewController {
    private let imageView = UIImageView()
    private var image: UIImage?
    
    convenience init(image: UIImage) {
        self.init()
        self.image = image
        
        self.setupComponent()
        self.setupLayout()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupComponent() {
        self.view.backgroundColor = .black
        
        self.imageView.image = image
        self.imageView.contentMode = .scaleAspectFit
        self.view.addSubview(self.imageView)
    }
    
    private func setupLayout() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        self.imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    }
}
