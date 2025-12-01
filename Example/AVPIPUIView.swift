//
//  PIPView.swift
//  FloatingClock
//
//  Created by hocgin on 11/30/25.
//
import PIPKit
import UIKit
import SwiftUI
import AVFAudio

extension Notification.Name {
    static let avPictureInPicture = Notification.Name("avPictureInPicture")
}


class AVPIPUIView: UIView, AVPIPUIKitUsable {

    var pipTargetView: UIView {
        self
    } // Return the subview that you want to show.
    
    private var hosting: UIHostingController<TimeDisplayCtl>!
    private var viewState: TimeDisplayCtl.ViewState = .init()
    private var deviceNotificationObserver: NSObjectProtocol?
    ///
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //            try audioSession.setCategory(.playback, options: nil)
            try audioSession.setCategory(.playback)
            //            try audioSession.setMode(.moviePlayback)
        } catch  {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    // 重写 bounds 属性
    override var bounds: CGRect {
        get {
            // 自定义 getter 行为，返回自定义的 bounds
            return .init(x: 0, y: 0, width: 300, height: 150)
        }
        set {
            // 自定义 setter 行为，设置新的 bounds
            super.bounds = newValue
            // 在这里你可以添加额外的逻辑，例如修改视图的大小、旋转等
            print("Bounds changed to: \(newValue)")
        }
    }

    private func commonInit() {
        setupAudioSession()
        
        // 将 SwiftUI View 添加到当前 UIView 中
        hosting = UIHostingController(
            rootView: TimeDisplayCtl(state: viewState)
        )
        guard let hostingView = hosting.view else { return }
        hostingView.backgroundColor = .green
                
        // 设置 hostingController.view 的大小
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(hostingView)
                
        // 使用 Auto Layout 设置 SwiftUI 视图的位置和大小
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: self.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        // 5. 设置刷新频率
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateClock)
        )
        if #available(iOS 15.0, *) {
            let maximumFramesPerSecond = Float(
                UIScreen.main.maximumFramesPerSecond
            )
            displayLink?.preferredFrameRateRange = CAFrameRateRange(
                minimum: min(80, maximumFramesPerSecond),
                maximum: maximumFramesPerSecond,
                preferred: maximumFramesPerSecond
            )
        } else {
            displayLink?.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond
        }
        displayLink?.add(to: .main, forMode: .common)
        
        /// 6.  事件监听
        deviceNotificationObserver = NotificationCenter.default
            .addObserver(
                forName: .avPictureInPicture,
                object: nil,
                queue: nil
            ) {
                guard let obj = $0.object as? Bool else {
                    self.toggle()
                    return
                }
                if obj {
                    self.start()
                } else {
                    self.stop()
                }
            }
    }
    
    @objc private func updateClock() {
        let fps = tickFPS(displayLink)
        DispatchQueue.main.async {
            self.viewState.date = .now
            self.viewState.fps = fps
        }
        renderPictureInPicture()
    }
    
    private func tickFPS(_ link: CADisplayLink?) -> Int? {
        guard let link else { return nil }
        if lastTimestamp == .zero {
            lastTimestamp = link.timestamp
            return nil
        }

        let delta = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp

        // 每秒回调次数 = 实时时钟 FPS
        return Int(1.0 / delta)
    }
    
    func start() {
        startPictureInPicture()
    }

    func stop() {
        stopPictureInPicture()
    }

    func toggle() {
        togglePictureInPicture()
    }
    
    static func startPIP() {
        NotificationCenter.default.post(name: .avPictureInPicture, object: true)
    }
    
    static func stopPIP() {
        NotificationCenter.default
            .post(name: .avPictureInPicture, object: false)
    }
    
    static func togglePIP() {
        NotificationCenter.default
            .post(name: .avPictureInPicture, object: nil)
    }
    
    
    deinit {
        displayLink?.invalidate()
        if let observer = deviceNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// 1. 创建 UIViewRepresentable，包装 MyCustomUIView
struct AVPIPUIViewRepresentable: UIViewRepresentable {
    
    // 这里的 MyCustomUIView 是你之前创建的自定义 UIView
    func makeUIView(context: Context) -> AVPIPUIView {
        AVPIPUIView()
    }
    
    // 2. 更新 UIView 的数据或状态（可以为空，取决于你是否需要动态更新）
    func updateUIView(_ uiView: AVPIPUIView, context: Context) {
        // 在这里更新自定义 UIView
        // 如果你需要更新 view，可以传递数据或其他状态
    }
}



//class AVPIPViewController: UIViewController, AVPIPUIKitUsable {
//    var pipTargetView: UIView {
//        view.translatesAutoresizingMaskIntoConstraints = true  // 允许 frame 控制
//        view.frame = .init(x: .zero, y: .zero, width: 200, height: 150)
//        view.bounds = .init(x: .zero, y: .zero, width: 200, height: 150)
//        NSLayoutConstraint.activate([
//            view.widthAnchor.constraint(equalToConstant: 200),  // 固定宽
//            view.heightAnchor.constraint(equalToConstant: 150), // 固定高
//            view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        view.sizeToFit()
//        return view
//    } // Return the subview that you want to show.
//    var renderPolicy: AVPIPKitRenderPolicy { .preferredFramesPerSecond(UIScreen.main.maximumFramesPerSecond) }
//    private var viewState: TimeDisplayCtl.ViewState = .init()
//    private var hosting: UIHostingController<TimeDisplayCtl>!
//    private var deviceNotificationObserver: NSObjectProtocol?
//    
//    ///
//    private var displayLink: CADisplayLink?
//    private var lastTimestamp: CFTimeInterval = 0
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .gray
////        self.preferredContentSize = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        // 通过 Auto Layout 让宽高自适应内容
////        view.setContentHuggingPriority(.required, for: .horizontal)
////        view.setContentHuggingPriority(.required, for: .vertical)
////        view.translatesAutoresizingMaskIntoConstraints = false
////        view.frame = .init(x: .zero, y: .zero, width: 200, height: 150)
////        view.bounds = .init(x: .zero, y: .zero, width: 200, height: 150)
////        NSLayoutConstraint.activate([
////            view.widthAnchor.constraint(equalToConstant: 200),  // 固定宽
////            view.heightAnchor.constraint(equalToConstant: 150), // 固定高
////            view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
////            view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
////        ])
//        
//        hosting = UIHostingController(rootView: TimeDisplayCtl(state: viewState))
//        addChild(hosting)
//        view.addSubview(hosting.view)
//        hosting.didMove(toParent: self)
//        
//        // 4. 设置布局（AutoLayout）
//        hosting.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            hosting.view.widthAnchor.constraint(equalToConstant: 200),   // 固定宽度 200
//            hosting.view.heightAnchor.constraint(equalToConstant: 150),  // 固定高度 150
//            hosting.view.centerXAnchor.constraint(equalTo: view.centerXAnchor), // 居中
//            hosting.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        
//        
//        
//        
//        // 5. 设置刷新频率
//        displayLink = CADisplayLink(target: self, selector: #selector(updateClock))
//        if #available(iOS 15.0, *) {
//            let maximumFramesPerSecond = Float(UIScreen.main.maximumFramesPerSecond)
//            displayLink?.preferredFrameRateRange = CAFrameRateRange(
//                minimum: min(80, maximumFramesPerSecond),
//                maximum: maximumFramesPerSecond,
//                preferred: maximumFramesPerSecond
//            )
//        } else {
//            displayLink?.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond
//        }
//        displayLink?.add(to: .main, forMode: .common)
//        
//        /// 6.  事件监听
//        deviceNotificationObserver = NotificationCenter.default
//            .addObserver(forName: .avPictureInPicture, object: nil, queue: nil) {
//                guard let obj = $0.object as? Bool else { return }
//                if obj {
//                    self.start()
//                } else {
//                    self.stop()
//                }
//            }
//    }
//    
//    @objc private func updateClock() {
//        let fps = tickFPS(displayLink)
//        DispatchQueue.main.async {
//            self.viewState.date = .now
//            self.viewState.fps = fps
//        }
//        renderPictureInPicture()
//    }
//    
//    private func tickFPS(_ link: CADisplayLink?) -> Int? {
//        guard let link else { return nil }
//        if lastTimestamp == .zero {
//            lastTimestamp = link.timestamp
//            return nil
//        }
//
//        let delta = link.timestamp - lastTimestamp
//        lastTimestamp = link.timestamp
//
//        // 每秒回调次数 = 实时时钟 FPS
//        return Int(1.0 / delta)
//    }
//    
//    func start() {
//        startPictureInPicture()
//    }
//
//    func stop() {
//        stopPictureInPicture()
//    }
//    
//    static func startPIP() {
//        NotificationCenter.default.post(name: .avPictureInPicture, object: true)
//    }
//    
//    static func stopPIP() {
//        NotificationCenter.default.post(name: .avPictureInPicture, object: false)
//    }
//    
//    
//    deinit {
//        displayLink?.invalidate()
//        if let observer = deviceNotificationObserver {
//            NotificationCenter.default.removeObserver(observer)
//        }
//    }
//}
//
//
//struct AVPIPViewRepresentable: UIViewControllerRepresentable {
//    
//    func makeUIViewController(context: Context) -> AVPIPViewController {
//        AVPIPViewController()
//    }
//    
//    func updateUIViewController(_ uiViewController: AVPIPViewController, context: Context) {
//        // 可以在这里更新 UIViewController 的内容
//    }
//}
