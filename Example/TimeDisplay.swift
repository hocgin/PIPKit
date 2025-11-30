import SwiftUI

struct TimeDisplay: View {
    var date: Date
    var dateFormat: String
    var fps: Int?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text("Apple")
                Spacer(minLength: .zero)
                if let fps {
                    Text("FPS \(fps)")
                }
            }
            Text("\(date.formatted())")
            HStack {
                Text("11-30 SUN")
                Spacer(minLength: .zero)
                WifiDisplay(strength: 1)
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
    }
}
