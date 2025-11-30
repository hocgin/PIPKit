//
//  TimeDisplayCtl.swift
//  FloatingClock
//
//  Created by hocgin on 11/30/25.
//

import SwiftUI

struct TimeDisplayCtl: View {
    @ObservedObject var state: ViewState
    
    var body: some View {
        TimeDisplay(
            date: state.date,
            dateFormat: state.dateFormat,
            fps: state.fps
        )
    }
}

extension TimeDisplayCtl {
    class ViewState: ObservableObject {
        @Published var date: Date = .now
        @Published var fps: Int?
        @Published var dateFormat: String = "HH:mm:ss.S"
    }
}
