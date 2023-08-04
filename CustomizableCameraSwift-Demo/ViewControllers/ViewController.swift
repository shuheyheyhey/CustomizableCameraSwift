//
//  ViewController.swift
//  CustomizableCameraSwift-Demo
//
//  Created by Shuhei Yukawa on 2023/08/01.
//

import UIKit
import CustomizableCameraSwift
import AVFoundation

class ViewController: UIViewController {
    private let cameraView: CameraView = CameraView(mode: .photo, frame: CGRect.zero)
    private let headerView = CaptureHeaderBarView(frame: CGRect.zero)
    private let bottomToolView = CaptureToolBarView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupComponent()
        self.setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.cameraView.restartSession()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cameraView.stopSession()
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func setupComponent() {
        do {
            try self.cameraView.setup()
            self.cameraView.delegate = self
            self.view.addSubview(self.cameraView)
        } catch {
            print(error.localizedDescription)
        }
        
        self.bottomToolView.delegate = self
        self.view.addSubview(self.bottomToolView)
        
        self.view.addSubview(self.headerView)
    }
    
    private func setupLayout() {
        self.bottomToolView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomToolView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.bottomToolView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.bottomToolView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bottomToolView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.headerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.cameraView.translatesAutoresizingMaskIntoConstraints = false
        self.cameraView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor).isActive = true
        self.cameraView.bottomAnchor.constraint(equalTo: self.bottomToolView.topAnchor).isActive = true
        self.cameraView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.cameraView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
}

extension ViewController: CameraViewDelegate {
    func didCaptured(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            let previewController = PreviewViewController(image: image)
            self?.navigationController?.pushViewController(previewController, animated: true)
        }
    }
}

extension ViewController: CaptureToolButtonDelegate {
    func didTapCaptureButton() {
        let flashMode = self.headerView.currentState
        self.cameraView.capture(flashMode: flashMode, orientation: self.managePhotoOrientation())
    }
    
    func didTapCancelButton() {
        
    }
    
    func didTapSwitchCameraButton() {
        // TODO: ボタン無効化
        Task {
            do {
                try await self.cameraView.switchCameraDevice()
            } catch {
                // TODO: エラー表示
                print(error.localizedDescription)
            }
        }
    }
    
    private func managePhotoOrientation() -> AVCaptureVideoOrientation {
        var currentDevice: UIDevice
        currentDevice = .current
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        var deviceOrientation: UIDeviceOrientation
        deviceOrientation = currentDevice.orientation

        if deviceOrientation == .portrait {
            return .portrait
        }
        if (deviceOrientation == .landscapeLeft){
            return .landscapeRight
        }
        if (deviceOrientation == .landscapeRight){
            return .landscapeLeft
        }
        if (deviceOrientation == .portraitUpsideDown){
            return .portraitUpsideDown
        }
        return .portrait
    }
}

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        guard let viewController = self.visibleViewController else { return false }
        return viewController.shouldAutorotate
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let viewController = self.visibleViewController else { return .portrait }
        return viewController.supportedInterfaceOrientations
    }
}
