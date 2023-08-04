//
//  CameraView.swift
//  CustomizableCameraSwift
//
//  Created by Shuhei Yukawa on 2023/08/01.
//

import Foundation
import AVFoundation
import Combine
import UIKit

public protocol CameraViewDelegate: AnyObject {
    func didCaptured(image: UIImage)
}

public enum CameraMode {
    case photo
    case video
}

public class CameraView: UIView {
    public weak var delegate: CameraViewDelegate?
    
    private var viewModel: CameraViewModel?
    private var focusView: UIView?
    private var disposeBag = Set<AnyCancellable>()
    
    public convenience init(mode: CameraMode, frame: CGRect) {
        self.init(frame: frame)
        if mode == .photo {
            self.viewModel = PhotoCameraViewModel()
        } else {
            fatalError("Not impremented")
        }
    }
    
    public override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        return layer as? AVCaptureVideoPreviewLayer
    }
    
    public func setup() throws {
        try self.viewModel?.setup()
        self.bind()
        self.setupPreviewLayer()
        self.setupGestureRecognizer()
    }
    
    public func stopSession() {
        self.viewModel?.updateSession(willStop: true)
    }
    
    public func restartSession() {
        self.viewModel?.updateSession(willStop: false)
    }
    
    private func bind() {
        if let viewModel = self.viewModel as? PhotoCameraViewModel {
            viewModel.didCaptured.sink(receiveValue: { image in
                self.delegate?.didCaptured(image: image)
            }).store(in: &self.disposeBag)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    private func setupPreviewLayer() {
        guard let session = self.viewModel?.session else { return }
        self.videoPreviewLayer?.session = session
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    public func capture(flashMode: AVCaptureDevice.FlashMode, orientation: AVCaptureVideoOrientation?) {
        // Flash the screen to signal taking a photo
        DispatchQueue.main.async { [weak self] in
            self?.videoPreviewLayer?.opacity = 0
            UIView.animate(withDuration: 0.25) {
                self?.videoPreviewLayer?.opacity = 1
            }
        }
        self.viewModel?.capture(flashMode: flashMode, orientation: orientation)
    }
    
    public func switchCameraDevice() async throws {
        try await self.viewModel?.switchCameraPosition()
    }
}

extension CameraView {
    private func setupGestureRecognizer() {
        let pinchGestureRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.onPinchGesture(_:)))
        self.addGestureRecognizer(pinchGestureRecognizer)
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func onPinchGesture(_ pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .changed:
            let newZoomFactor = pinch.scale * (self.viewModel?.currentZoomFactor ?? 1)
            do {
                try self.viewModel?.updateZoom(scale: newZoomFactor)
            } catch {
                // TODO: エラー処理
                print(error.localizedDescription)
            }
        default: break
        }
        
    }
    
    @objc private func onTapGesture(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: self)
        guard let pointInCamera = self.videoPreviewLayer?.captureDevicePointConverted(fromLayerPoint: point) else { return }
        
        do {
            try self.viewModel?.updateFocus(point: pointInCamera)
            self.updateFocusView(point: point)
        } catch {
            // TODO: エラー処理
            print(error.localizedDescription)
        }
        
    }
    
    private func updateFocusView(point: CGPoint) {
        self.focusView?.removeFromSuperview()
        
        let focusView = UIView()
        focusView.frame = CGRect(x: 0, y: 0, width: bounds.width * 0.3, height: bounds.width * 0.3)
        focusView.layer.borderWidth = 1
        focusView.layer.borderColor = UIColor.systemYellow.cgColor
        addSubview(focusView)
        
        self.focusView = focusView
        focusView.center = point
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: []) { [weak self] in
            guard let self = self else { return }
            focusView.frame = CGRect(x: point.x - (self.bounds.width * 0.075), y: point.y - (self.bounds.width * 0.075), width: (self.bounds.width * 0.15), height: (self.bounds.width * 0.15)) // タップしたポイントに向けて縮む
        } completion: { (UIViewAnimatingPosition) in
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self](Timer) in
                focusView.removeFromSuperview()
                try? self?.viewModel?.updateFocusMode(mode: AVCaptureDevice.FocusMode.continuousAutoFocus)
            }
        }
    }
}
