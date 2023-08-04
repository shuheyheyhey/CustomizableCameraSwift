//
//  CameraViewModel.swift
//  CustomizableCameraSwift
//
//  Created by Shuhei Yukawa on 2023/08/03.
//

import Foundation
import AVFoundation
import Combine
import UIKit

protocol CameraViewModel {
    var session: AVCaptureSession { get }
    var currentZoomFactor: CGFloat { get }
    func setup() throws
    func capture(flashMode: AVCaptureDevice.FlashMode, orientation: AVCaptureVideoOrientation?)
    func updateZoom(scale: CGFloat) throws
    func updateFocus(point: CGPoint) throws
    func switchCameraPosition() async throws
    func updateFocusMode(mode: AVCaptureDevice.FocusMode) throws
    func updateSession(willStop: Bool)
}

final class PhotoCameraViewModel: CameraViewModel, PhotoCaptureSessionDelegate {
    let didCaptured = PassthroughSubject<UIImage, Never>()
    private let captureSession = PhotoCaptureSession()
    
    init() {
        self.captureSession.delegate = self
    }
    
    var session: AVCaptureSession {
        self.captureSession.captureSession
    }
    
    var currentZoomFactor: CGFloat {
        self.captureSession.currentZoomFactor
    }
    
    
    func setup() throws {
        try self.captureSession.setupCaptureSession()
    }
    
    func capture(flashMode: AVCaptureDevice.FlashMode, orientation: AVCaptureVideoOrientation?) {
        self.captureSession.capture(flashMode: flashMode, orientation: orientation)
    }
    
    func switchCameraPosition() async throws {
        try await self.captureSession.switchCamera()
    }
    
    func updateZoom(scale: CGFloat) throws {
        try self.captureSession.updateZoom(scale: scale)
    }
    
    func updateFocus(point: CGPoint) throws {
        try self.captureSession.updateFocus(point: point)
    }
    
    func didCaptured(image: UIImage) {
        self.didCaptured.send(image)
    }
    
    func updateFocusMode(mode: AVCaptureDevice.FocusMode) throws {
        try self.captureSession.updateFocusMode(mode: mode)
    }
    
    func updateSession(willStop: Bool) {
        if willStop {
            self.captureSession.stopSession()
            return
        }
        self.captureSession.startSession()
    }
}
