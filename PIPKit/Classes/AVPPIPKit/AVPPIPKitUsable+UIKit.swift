//
//  AVPIPKitUsable+UIKit.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/08.
//

import Foundation
import UIKit
import Combine

@available(iOS 15.0, *)
public protocol AVPPIPUIKitUsable: AVPPIPKitUsable {
    
    var pipTargetView: UIView { get }
    var renderPolicy: AVPIPKitRenderPolicy { get }
    var exitPublisher: AnyPublisher<Void, Never> { get }
    
}

@available(iOS 15.0, *)
public extension AVPPIPUIKitUsable {
    
    var renderPolicy: AVPIPKitRenderPolicy {
        .preferredFramesPerSecond(UIScreen.main.maximumFramesPerSecond)
    }
    
}

@available(iOS 15.0, *)
public extension AVPPIPUIKitUsable where Self: UIViewController {
    
    var pipTargetView: UIView { view }
    var renderer: AVPIPKitRenderer {
        setupRendererIfNeeded()
        return avUIKitRenderer.unsafelyUnwrapped
    }
    var exitPublisher: AnyPublisher<Void, Never> {
        setupRendererIfNeeded()
        return avUIKitRenderer.unsafelyUnwrapped.exitPublisher
    }
    
    func startPictureInPicture() {
        setupIfNeeded()
        pvideoController?.start()
    }
    
    func stopPictureInPicture() {
        assert(videoController != nil)
        pvideoController?.stop()
    }
    
    func togglePictureInPicture() {
        pvideoController?.toggle()
    }
    
    // If you want to update the screen, execute the following additional code.
    func renderPictureInPicture() {
        setupRendererIfNeeded()
        avUIKitRenderer?.render()
    }
    
    // MARK: - Private
    private func setupRendererIfNeeded() {
        guard avUIKitRenderer == nil else {
            return
        }
        
        avUIKitRenderer = AVPIPUIKitRenderer(targetView: pipTargetView, policy: renderPolicy)
    }
    
    private func setupIfNeeded() {
        guard videoController == nil else {
            return
        }
        
        pvideoController = createVideoController()
    }
    
}

@available(iOS 15.0, *)
public extension AVPPIPUIKitUsable where Self: UIView {
    
    var pipTargetView: UIView { self }
    var renderer: AVPIPKitRenderer {
        setupRendererIfNeeded()
        return avUIKitRenderer.unsafelyUnwrapped
    }
    var exitPublisher: AnyPublisher<Void, Never> {
        setupRendererIfNeeded()
        return avUIKitRenderer.unsafelyUnwrapped.exitPublisher
    }
    
    func startPictureInPicture() {
        setupIfNeeded()
        pvideoController?.start()
    }
    
    func togglePictureInPicture() {
        setupIfNeeded()
        pvideoController?.toggle()
    }
    
    func stopPictureInPicture() {
//        assert(pvideoController != nil)
        pvideoController?.stop()
    }
    
    // If you want to update the screen, execute the following additional code.
    func renderPictureInPicture() {
        setupRendererIfNeeded()
        avUIKitRenderer?.render()
    }
    
    // MARK: - Private
    private func setupRendererIfNeeded() {
        guard avUIKitRenderer == nil else {
            return
        }
        
        avUIKitRenderer = AVPIPUIKitRenderer(targetView: pipTargetView, policy: renderPolicy)
    }
    
    private func setupIfNeeded() {
        guard videoController == nil else {
            return
        }
        
        pvideoController = createVideoController()
    }
    
}
