//
//  AppDelegate.swift
//  Example
//
//  Created by Kofktu on 2022/01/03.
//

import SwiftUI

@main
struct BootApp: App {
    
    var body: some Scene {
        WindowGroup {
            VStack {
                AVPPIPUIViewRepresentable()
                // 在主 App 窗口中显示时钟内容
                Button("启动 PiP 悬浮时钟") {
                    AVPPIPUIView.startPIP()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Button("关闭 悬浮时钟") {
                    AVPPIPUIView.stopPIP()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Button("切换 悬浮时钟") {
                    AVPPIPUIView.togglePIP()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    
    var body1: some Scene {
        WindowGroup {
            VStack {
                AVPIPUIViewRepresentable()
                // 在主 App 窗口中显示时钟内容
                Button("启动 PiP 悬浮时钟") {
                    AVPIPUIView.startPIP()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Button("关闭 悬浮时钟") {
                    AVPIPUIView.stopPIP()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Button("切换 悬浮时钟") {
                    AVPIPUIView.togglePIP()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
