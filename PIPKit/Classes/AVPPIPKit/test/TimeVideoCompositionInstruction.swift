//
//  VideoCompositionInstruction.swift
//  FloatingClock
//
//  Created by wl on 2020/12/17.
//

import UIKit
import AVFoundation

class TimeVideoCompositionInstruction:NSObject, AVVideoCompositionInstructionProtocol {
   
    // Protocol Property
    var timeRange: CMTimeRange
    var enablePostProcessing = false
    var containsTweening = true
    var requiredSourceTrackIDs: [NSValue]?
    var passthroughTrackID = kCMPersistentTrackID_Invalid
    var layerInstructions: [AVVideoCompositionLayerInstruction]?
    
    // render string
    var image: UIImage?
    

    init(_ requiredSourceTrackIDs: [NSValue]?, timeRange: CMTimeRange) {
        self.requiredSourceTrackIDs = requiredSourceTrackIDs
        self.timeRange = timeRange
    }
    
    // 4. 【关键】实现 dictionaryRepresentation 避免 crash
    @objc dynamic var dictionaryRepresentation: [String: Any] {
        [
            "timeRange": NSValue(timeRange: timeRange),
            "enablePostProcessing": enablePostProcessing,
            "containsTweening": containsTweening,
//            "passthroughTrackID": passthroughTrackID,
//            "requiredSourceTrackIDs": requiredSourceTrackIDs,
//            "layerInstructions": layerInstructions,
            "image": image,
        ]
    }
    
    func getPixelBuffer(_ renderContext: AVVideoCompositionRenderContext) -> CVPixelBuffer? {
        let width = Int(renderContext.size.width)
        let height = Int(renderContext.size.height)
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any ,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any,
                     kCVPixelBufferIOSurfacePropertiesKey: NSDictionary()
        ] as CFDictionary
        
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let cgContext = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        guard let context = cgContext else {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: Int(renderContext.size.width), height: Int(renderContext.size.height))
        
        context.setFillColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor)
        context.fill(rect)
        
        context.saveGState()
        /// ==================================================
        ///
        if let cgImage = image?.cgImage {
            context.draw(cgImage, in: rect)
        }
        ///
        /// ==================================================
        context.restoreGState()
        
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
   
}

