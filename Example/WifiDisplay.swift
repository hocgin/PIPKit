

import SwiftUI

/// 像素风格的 WiFi 状态图标
struct PixelWifiIcon: View {
    
    // MARK: - 可配置属性
    
    /// 当前信号强度 (0 到 4)
    var strength: Int
    
    /// 像素主色 (例如：黑客绿)
    var pixelColor: Color = Color(red: 0.0, green: 1.0, blue: 0.25)
    
    /// 熄灭的像素颜色
    var dimColor: Color = Color(red: 0.05, green: 0.1, blue: 0.05)
    
    /// 单个像素的尺寸，用于控制整体大小和像素感
    var pixelSize: CGFloat = 4.0
    
    // MARK: - 辅助视图
    
    /// 渲染单个 WiFi 条的辅助函数
    @ViewBuilder
    private func wifiBar(heightMultiplier: Int, barIndex: Int) -> some View {
        // 判断当前条是否应该被点亮
        let isLit = strength >= barIndex
        
        Rectangle()
            .fill(isLit ? pixelColor : dimColor)
            .frame(
                width: pixelSize,
                height: CGFloat(heightMultiplier) * pixelSize
            )
        // 添加辉光效果
//            .shadow(
//                color: isLit ? pixelColor.opacity(0.8) : .clear,
//                radius: isLit ? 2 : 0
//            )
    }
    
    // MARK: - 主体视图
    
    var body: some View {
        HStack(alignment: .bottom, spacing: pixelSize * 0.5) { // 间距为半个像素大小
            
            // 柱状条 1 (最矮)
            wifiBar(heightMultiplier: 1, barIndex: 1)
            
            // 柱状条 2
            wifiBar(heightMultiplier: 2, barIndex: 2)
            
            // 柱状条 3
            wifiBar(heightMultiplier: 3, barIndex: 3)
            
            // 柱状条 4 (最高)
            wifiBar(heightMultiplier: 4, barIndex: 4)
            
        }
        .padding(pixelSize) // 增加一些内边距
    }
}

struct WifiDisplay: View {
    var strength: Int
    var body: some View {
        if strength == 1 {
            PixelWifiIcon(
                strength: 1,
                pixelColor: .red,
                dimColor: Color.red.opacity(0.1)
            )
        } else if strength == 2 {
            PixelWifiIcon(
                strength: 2,
                pixelColor: .yellow,
                dimColor: Color.yellow.opacity(0.1)
            )
        } else if strength == 3{
            PixelWifiIcon(strength: 3)
        } else if strength == 4{
            PixelWifiIcon(strength: 4)
        } else {
            PixelWifiIcon(
                strength: 0,
                pixelColor: .red,
                dimColor: Color.red.opacity(0.1)
            )
        }
    }
}

// MARK: - 预览 (Preview)
#Preview {
    VStack(spacing: 30) {
        Text("信号强度示例").font(.title).foregroundColor(.white)
        
        HStack(spacing: 40) {
            // 强度 0 (断开)
            WifiDisplay(strength: 0)
            WifiDisplay(strength: 1)
            WifiDisplay(strength: 2)
            WifiDisplay(strength: 3)
            WifiDisplay(strength: 4)
        }
    }
    .preferredColorScheme(.dark)
    .padding()
    .background(Color.black)
}
