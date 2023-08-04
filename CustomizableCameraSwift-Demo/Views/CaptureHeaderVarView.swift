//
//  CaptureHeaderVarView.swift
//  AlberoCameraSwift-Demo
//
//  Created by Shuhei Yukawa on 2023/08/04.
//

import Foundation
import AVFoundation
import UIKit

final class CaptureHeaderBarView: UIView {
    var currentState: AVCaptureDevice.FlashMode { self.state }
    
    private var state: AVCaptureDevice.FlashMode = .auto
    private let stackView = UIStackView()
    private let flashButton = UIButton()
    private let autoButton = UIButton()
    private let onButton = UIButton()
    private let offButton = UIButton()
    
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
        
        self.setupFlashButton()
        self.addSubview(self.flashButton)
        
        self.stackView.axis = .horizontal
        self.stackView.spacing = 10
        self.stackView.alignment = .bottom
        self.stackView.distribution = .equalSpacing
        self.addSubview(self.stackView)
        
        self.setupFlashModeButtons()
        self.stackView.addArrangedSubview(self.autoButton)
        self.stackView.addArrangedSubview(self.onButton)
        self.stackView.addArrangedSubview(self.offButton)
        
        self.stackView.isHidden = true
    }
    
    private func setupFlashButton() {
        self.flashButton.tintColor = .white
        self.flashButton.setImage(UIImage(systemName: "bolt.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.flashButton.contentHorizontalAlignment = .fill // オリジナルの画像サイズを超えて拡大（水平）
        self.flashButton.contentVerticalAlignment = .fill // オリジナルの画像サイズを超えて拡大(垂直)
        self.flashButton.addTarget(self, action: #selector(self.didTapFlashButton), for: .touchDown)
    }
    
    private func setupFlashModeButtons() {
        self.autoButton.setTitle("Auto", for: .normal)
        self.autoButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
        self.autoButton.setContentHuggingPriority(.required, for: .horizontal)
        self.autoButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.autoButton.addTarget(self, action: #selector(self.didTapAutoButton), for: .touchDown)
        
        self.onButton.setTitle("ON", for: .normal)
        self.onButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
        self.onButton.setContentHuggingPriority(.required, for: .horizontal)
        self.onButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.onButton.addTarget(self, action: #selector(self.didTapOnButton), for: .touchDown)
        
        self.offButton.setTitle("OFF", for: .normal)
        self.offButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
        self.offButton.setContentHuggingPriority(.required, for: .horizontal)
        self.offButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.offButton.addTarget(self, action: #selector(self.didTapOffButton), for: .touchDown)
    }
    
    private func updateFlashMode(state: AVCaptureDevice.FlashMode) {
        self.state = state
        switch state {
        case .auto:
            self.flashButton.setImage(UIImage(systemName: "bolt.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.flashButton.tintColor = .white
        case .on:
            self.flashButton.setImage(UIImage(systemName: "bolt.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.flashButton.tintColor = .yellow
        case .off:
            self.flashButton.setImage(UIImage(systemName: "bolt.slash.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.flashButton.tintColor = .white
        @unknown default:
            return
        }
    }
    
    private func setupLayout() {
        self.flashButton.translatesAutoresizingMaskIntoConstraints = false
        self.flashButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.flashButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.flashButton.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        self.flashButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.flashButton.bottomAnchor).isActive = true
        self.stackView.leftAnchor.constraint(equalTo: self.flashButton.rightAnchor, constant: 10).isActive = true
        self.stackView.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor).isActive = true
    }
}

extension CaptureHeaderBarView {
    private func animateFlashModeButtons(willHide: Bool) {
        if !willHide {
            // 表示時はすぐ表示してほしいので
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.stackView.alpha = 1.0
                self?.stackView.isHidden = false
            }
            return
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: []) { [weak self] in
            guard let self = self else { return }
            self.stackView.alpha = 0.0
        } completion: { [weak self](UIViewAnimatingPosition) in
            self?.stackView.isHidden = true
        }
    }
    
    @objc
    func didTapFlashButton() {
        self.animateFlashModeButtons(willHide: !self.stackView.isHidden)
    }
    
    @objc
    func didTapAutoButton() {
        self.updateFlashMode(state: .auto)
        self.animateFlashModeButtons(willHide: true)
    }
    
    @objc
    func didTapOnButton() {
        self.updateFlashMode(state: .on)
        self.animateFlashModeButtons(willHide: true)
    }
    
    @objc
    func didTapOffButton() {
        self.updateFlashMode(state: .off)
        self.animateFlashModeButtons(willHide: true)
    }
}
