//
//  CaptureSession.swift
//  CustomizableCameraSwift
//
//  Created by Shuhei Yukawa on 2023/08/01.
//

import Foundation
import AVFoundation
import UIKit

public enum CaptureSessionError: Error {
    case notFoundAnyDevice
    case notFoundInnerCamera
    case notFoundBackCamera
    case notFoundCurrentDevice
}

public class CaptureSession: NSObject  {
    public let captureSession = AVCaptureSession()
    
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    internal var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    internal var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    internal var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    internal var photoOutput : AVCapturePhotoOutput?
    
    public var currentZoomFactor: CGFloat {
        return self.currentDevice?.videoZoomFactor ?? 1
    }
    
    public override init() {
        super.init()
    }
    
    deinit {
        self.stopSession()
    }
    
    public func setupCaptureSession() throws {
        self.setupDevice()
        self.captureSession.beginConfiguration()
        // カメラの画質の設定
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        try self.setupInputOutput()
        
        self.captureSession.commitConfiguration()
        
        self.startSession()
    }
    
    public func switchCamera() async throws {
        if currentDevice?.isEqual(self.mainCamera) ?? false {
            guard let innerCamera = self.innerCamera else {
                throw CaptureSessionError.notFoundInnerCamera
            }
            self.currentDevice = innerCamera
        } else {
            guard let mainCamera = self.mainCamera else {
                throw CaptureSessionError.notFoundBackCamera
            }
            self.currentDevice = mainCamera
        }
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                self.captureSession.beginConfiguration()
                
                self.captureSession.inputs.forEach { self.captureSession.removeInput($0) }
                guard let current = self.currentDevice else {
                    continuation.resume(throwing: CaptureSessionError.notFoundCurrentDevice)
                    return
                }
                
                do {
                    let input = try AVCaptureDeviceInput(device: current)
                    if self.captureSession.canAddInput(input) {
                        self.captureSession.addInput(input)
                        self.captureSession.commitConfiguration()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func startSession() {
        Task {
            self.captureSession.startRunning()
        }
    }
    
    public func stopSession() {
        Task {
            self.captureSession.stopRunning()
        }
    }
    
    public func updateZoom(scale: CGFloat) throws {
        guard let current = self.currentDevice else { return }
        if current.maxAvailableVideoZoomFactor < scale || current.minAvailableVideoZoomFactor > scale { return }
        defer { current.unlockForConfiguration() }
        
        try current.lockForConfiguration()
        current.ramp(toVideoZoomFactor: scale, withRate: 32.0)
    }
    
    public func updateFocus(point: CGPoint) throws {
        guard let current = self.currentDevice else { return }
        defer { current.unlockForConfiguration() }
        try current.lockForConfiguration()
        current.focusPointOfInterest = point
        current.focusMode = .autoFocus
    }
    
    public func updateFocusMode(mode: AVCaptureDevice.FocusMode) throws {
        guard let current = self.currentDevice else { return }
        defer { current.unlockForConfiguration() }
        try current.lockForConfiguration()
        current.focusMode = .continuousAutoFocus
    }
    
    
    private func setupDevice() {
        // バックカメラ
        if let tripleCameraDevice = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            //トリプルカメラ
            self.mainCamera = tripleCameraDevice
        } else if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            //デュアルカメラ（広角・望遠）
            self.mainCamera = dualCameraDevice
        } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
           //デュアルカメラ（広角・超広角）
            self.mainCamera = dualWideCameraDevice
        } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            //シングルカメラ
            self.mainCamera = backCameraDevice
        }
        
        // フロントカメラ
        if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            //インカメラ
            self.innerCamera = frontCameraDevice
        }
        
        if let mainCamera = self.mainCamera {
            // 起動時のカメラを設定
            currentDevice = mainCamera
        } else if let innerCamera = self.innerCamera {
            currentDevice = innerCamera
        }
    }

    // 入出力データの設定
    private func setupInputOutput() throws {
        // 指定したデバイスを使用するために入力を初期化
        let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
        // 指定した入力をセッションに追加
        captureSession.addInput(captureDeviceInput)
        // 出力データを受け取るオブジェクトの作成
        photoOutput = AVCapturePhotoOutput()
        // 出力ファイルのフォーマットを指定
        photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        captureSession.addOutput(photoOutput!)
    }
}

public protocol PhotoCaptureSessionDelegate: AnyObject {
    func didCaptured(image: UIImage)
}

public final class PhotoCaptureSession: CaptureSession, AVCapturePhotoCaptureDelegate {
    public weak var delegate: PhotoCaptureSessionDelegate?
    
    public func capture(flashMode: AVCaptureDevice.FlashMode, orientation: AVCaptureVideoOrientation?) {
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        settings.flashMode = flashMode
        
        // 必要があれば画面回転の設定
        if let orientation = orientation {
            self.photoOutput?.connection(with: .video)?.videoOrientation = orientation
        }
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            // TODO: エラー処理
            return
        }
        
        self.delegate?.didCaptured(image: image)
        self.stopSession()
    }
}
