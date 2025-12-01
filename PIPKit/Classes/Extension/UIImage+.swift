import UIKit
import AVFoundation
import CoreMedia

extension UIImage {
    
    func cmSampleBuffer(
        preferredFramesPerSecond: Int,
        pixelBufferOptions: [String: Any]? = nil
    ) -> CMSampleBuffer? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // 1. 创建 CVPixelBuffer（BGRA，top-down）
        let options: [String: Any] = pixelBufferOptions ?? [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            nil,
            width,
            height,
            kCVPixelFormatType_32BGRA,  // iOS GPU 最友好的通用格式
            options as CFDictionary?,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        // 2. 绘制：关键——不翻转！用 correct bitmapInfo 保证方向
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        // ✅ 使用 CGColorSpaceCreateDeviceRGB() + 正确 bitmapInfo
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        
        guard let context = CGContext(
            data: baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        
        // ✅ 清空背景（防止残留）
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        
        // ✅ 关键修正：不再 translate/scale！直接 draw
        // 因为：CVPixelBuffer + BGRA + byteOrder32Little 在 iOS 是 top-left layout
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 3. 创建 format description
        var formatDesc: CMVideoFormatDescription?
        let fmtStatus = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: nil,
            imageBuffer: buffer,
            formatDescriptionOut: &formatDesc
        )
        guard fmtStatus == noErr, let desc = formatDesc else { return nil }
        
        // 4. 时间信息
        let duration = CMTime(value: 1, timescale: Int32(preferredFramesPerSecond))
        
        let presentationTimeStamp = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: CMTimeScale(preferredFramesPerSecond))
        let decodeTimeStamp = CMTime.invalid
        
        var timing = CMSampleTimingInfo(
            duration: duration,
            presentationTimeStamp: presentationTimeStamp,
            decodeTimeStamp: decodeTimeStamp
        )
        
        // 5. 创建 SampleBuffer
        var sampleBuffer: CMSampleBuffer?
        let sbStatus = CMSampleBufferCreateForImageBuffer(
            allocator: nil,
            imageBuffer: buffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: desc,
            sampleTiming: &timing,
            sampleBufferOut: &sampleBuffer
        )
        guard sbStatus == noErr, let sb = sampleBuffer else { return nil }
        
        return sb
    }
}
