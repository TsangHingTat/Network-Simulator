//
//  ContentView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MapView(deviceData: DeviceTemplates.homeNetwork())
    }
}

#Preview {
    ContentView()
}
