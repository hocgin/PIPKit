//
//  AVPIPKitVideoProvider.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import QuartzCore
import UIKit
import AVKit
import AVFoundation
import CoreVideo
import Combine


@available(iOS 15.0, *)
extension AVPPIPKitUsable {

    func createVideoController() -> AVPPIPKitVideoController {
        AVPPIPKitVideoController(
            renderer: renderer,
            audioSessionCategory: pipAudioSessionCategory
        )
    }
    
}

@available(iOS 15.0, *)
final class PPIPVideoProvider: NSObject {
    
    private(set) var isRunning: Bool = false
    let renderer: AVPIPKitRenderer
    let pipAudioSessionCategory: AVAudioSession.Category
    
    private let pipContainerView = UIView()
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        stop()
    }
    
    init(renderer: AVPIPKitRenderer, audioSessionCategory: AVAudioSession.Category) {
        self.renderer = renderer
        self.pipAudioSessionCategory = audioSessionCategory
        let url = Bundle.module.url(forResource: "temp", withExtension: "mov")!
        self.asset = AVAsset(url: url)
        
        self.item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)
        
        self.playerLayer = AVPlayerLayer()
        self.playerLayer.player = player
        
        super.init()
        self.setupVideo()
        
    }
        
    func start() {
        if isRunning {
            return
        }
        
        isRunning = true
        
        if let window = UIApplication.shared._keyWindow {
            pipContainerView.backgroundColor = .clear
            pipContainerView.alpha = 0.0
            window.addSubview(pipContainerView)
            window.sendSubviewToBack(pipContainerView)
            playerLayer.backgroundColor = UIColor.clear.cgColor
            playerLayer.videoGravity = .resizeAspect
            pipContainerView.layer.addSublayer(playerLayer)
        }
        
        let renderPublisher = renderer.renderPublisher
            .receive(on: DispatchQueue.main)
            .share()
        
        renderPublisher
            .map { $0.size }
            .removeDuplicates()
            .map { CGRect(origin: .zero, size: $0) }
            .sink(receiveValue: { [weak self] bounds in
                debugPrint("bounds = \(bounds)")
                self?.pipContainerView.frame = bounds
                self?.playerLayer.frame = bounds
            })
            .store(in: &cancellables)
        
        renderPublisher
            .sink(receiveValue: { [weak self] image in
                self?.timeInstruction?.image = image
                if let videoComposition = self?.videoComposition {
                    self?.item.videoComposition = videoComposition
                }
            })
            .store(in: &cancellables)
        
        renderer.start()
    }
    
    func stop() {
        guard isRunning else {
            return
        }
        
        pipContainerView.removeFromSuperview()
        renderer.stop()
        isRunning = false
    }
    
    var asset: AVAsset
    var item: AVPlayerItem
    var player: AVPlayer
    var playerLayer: AVPlayerLayer
    var videoComposition: AVMutableVideoComposition?
    var timeInstruction: TimeVideoCompositionInstruction?
    var observation: NSKeyValueObservation?
}

extension PPIPVideoProvider {
    
    func setupVideo() {
        observation = player.observe(\.status, options: .new, changeHandler: {[weak self] (player, _) in
            guard let self = self else { return }
            switch player.status {
            case .readyToPlay:
                print("readyToPlay")
                self.loadAssetProperty()
            case .failed:
                print("failed")
            case .unknown:
                print("unknown")
            @unknown default:break
            }
        })
    }
    
    func loadAssetProperty() {
        self.asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) { [weak self] in
            guard let self = self else { return }
            var error: NSError?
            let durationStatus = self.asset.statusOfValue(forKey: "duration", error: &error)
            let tracksStatus = self.asset.statusOfValue(forKey: "tracks", error: &error)
            switch (durationStatus, tracksStatus){
            case (.loaded, .loaded):
                DispatchQueue.main.async {
                    self.setupComposition()
                }
            default:
                print("load failed")
            }
        }
    }
    
    
    func setupComposition()  {
        
        // For best performance, ensure that the duration and tracks properties of the asset are already loaded before invoking this method.
        videoComposition = AVMutableVideoComposition(propertiesOf: asset)
        let instructions = videoComposition?.instructions as! [AVVideoCompositionInstruction]
        var newInstructions: [AVVideoCompositionInstructionProtocol] = []
        
        guard let instruction = instructions.first else {
            return
        }
        let layerInstructions = instruction.layerInstructions
        // TrackIDs
        var trackIDs: [CMPersistentTrackID] = []
        for layerInstruction in layerInstructions {
            trackIDs.append(layerInstruction.trackID)
        }
        timeInstruction = TimeVideoCompositionInstruction(trackIDs as [NSValue], timeRange: instruction.timeRange)
        if let timeInstruction {
            timeInstruction.layerInstructions = layerInstructions
            newInstructions.append(timeInstruction)
        }
        videoComposition?.instructions = newInstructions
        
        self.videoComposition?.customVideoCompositorClass = TimeVideoComposition.self
        item.videoComposition = videoComposition
    }
}


@available(iOS 15.0, *)
extension PPIPVideoProvider: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip will start")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip did start")
    }
}
