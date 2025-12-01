//
//  BundleFinder.swift
//  PIPKit
//
//  Created by hocgin on 12/2/25.
//


//
//  BundleFinder.swift
//  PIPKit
//
//  Created by hocgin on 12/1/25.
//


#if canImport(SwiftUI) && !os(watchOS)
import SwiftUI
#endif

extension Bundle {
    /// SPM 自动生成的 Bundle.module 的兼容实现
    static var module: Bundle {
        #if SWIFT_PACKAGE
        // 1. 尝试通过当前类定位（最可靠）
        let bundleName = "PIPKit_PIPKit" // ← 替换为 "PackageName_TargetName"
        let candidates = [
            // 开发时（调试）
            Bundle.main.resourceURL,
            Bundle.main.bundleURL,
            // 发布时（Framework）
            Bundle(for: BundleFinder.self).resourceURL,
            Bundle(for: BundleFinder.self).bundleURL,
        ]
        .compactMap { $0 }
        .map { $0.appendingPathComponent(bundleName + ".bundle") }
        .filter { Bundle(url: $0) != nil }

        if let bundle = candidates.first {
            return Bundle(url: bundle)!
        }

        // 2. 兜底：返回主 bundle（不推荐，但避免 crash）
        return Bundle.main
        #else
        // 非 SPM 环境（如直接集成到 App）
        return Bundle(for: BundleFinder.self)
        #endif
    }
}

// 辅助类：用于定位当前模块的类
private final class BundleFinder {}
