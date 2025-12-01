//
//  AVPIPKitUsable.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import UIKit
import AVKit


@available(iOS 15.0, *)
public protocol AVPPIPKitUsable {
    
    var renderer: AVPIPKitRenderer { get }
    
    /// `pipAudioSessionCategory` supports only `.playback` or `.playAndRecord`.
    var pipAudioSessionCategory: AVAudioSession.Category { get }
    
    func startPictureInPicture()
    func stopPictureInPicture()
    
}

@available(iOS 15.0, *)
public extension AVPPIPKitUsable {
    
    var isAVKitPIPSupported: Bool {
        PIPKit.isAVPIPKitSupported
    }
    
    var pipAudioSessionCategory: AVAudioSession.Category { .playback }
    
}

