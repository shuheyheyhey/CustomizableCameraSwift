//
//  CaptureToolBarView.swift
//  AlberoCameraSwift-Demo
//
//  Created by Shuhei Yukawa on 2023/08/04.
//

import Foundation
import AVFoundation
import UIKit

protocol CaptureToolButtonDelegate: AnyObject {
    func didTapCaptureButton()
    func didTapCancelButton()
    func didTapSwitchCameraButton()
}

class CaptureToolBarView: UIView {
    weak var delegate: CaptureToolButtonDelegate?
    
    private let captureButton = UIButton()
    private let cancelButton = UIButton()
    private let switchCameraButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupComponent()
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupComponent() {
        self.backgroundColor = .black
        
        self.setupCancelButton()
        self.addSubview(self.cancelButton)
        
        self.setupCaptureButton()
        self.addSubview(self.captureButton)

        self.setupSwitchCameraButton()
        self.addSubview(self.switchCameraButton)
    }
    
    private func setupLayout() {
        self.captureButton.translatesAutoresizingMaskIntoConstraints = false
        self.captureButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.captureButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        self.captureButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.captureButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.centerYAnchor.constraint(equalTo: self.captureButton.centerYAnchor).isActive = true
        self.cancelButton.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        self.cancelButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        self.cancelButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        self.switchCameraButton.centerYAnchor.constraint(equalTo: self.captureButton.centerYAnchor).isActive = true
        self.switchCameraButton.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        self.switchCameraButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.switchCameraButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupCaptureButton() {
        self.captureButton.tintColor = .white
        self.captureButton.imageView?.contentMode = .scaleAspectFit
        self.captureButton.contentHorizontalAlignment = .fill // オリジナルの画像サイズを超えて拡大（水平）
        self.captureButton.contentVerticalAlignment = .fill // オリジナルの画像サイズを超えて拡大(垂直)
        self.captureButton.setImage(UIImage(systemName: "circle"), for: .normal)
        self.captureButton.addTarget(self, action: #selector(self.didTapCaptureButton), for: .touchDown)
    }
    
    private func setupSwitchCameraButton() {
        self.switchCameraButton.tintColor = .white
        self.switchCameraButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.switchCameraButton.contentHorizontalAlignment = .fill // オリジナルの画像サイズを超えて拡大（水平）
        self.switchCameraButton.contentVerticalAlignment = .fill // オリジナルの画像サイズを超えて拡大(垂直)
        self.switchCameraButton.addTarget(self, action: #selector(self.didTapSwitchCameraButton), for: .touchDown)
    }
    
    private func setupCancelButton() {
        self.cancelButton.tintColor = .white
        self.cancelButton.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.cancelButton.contentHorizontalAlignment = .fill // オリジナルの画像サイズを超えて拡大（水平）
        self.cancelButton.contentVerticalAlignment = .fill // オリジナルの画像サイズを超えて拡大(垂直)
        self.cancelButton.addTarget(self, action: #selector(self.didTapCancelButton), for: .touchUpInside)
    }
    
    @objc
    func didTapCaptureButton() {
        self.delegate?.didTapCaptureButton()
    }
    
    @objc
    func didTapSwitchCameraButton() {
        self.delegate?.didTapSwitchCameraButton()
    }
    
    @objc
    func didTapCancelButton() {
        self.delegate?.didTapCancelButton()
    }
}
