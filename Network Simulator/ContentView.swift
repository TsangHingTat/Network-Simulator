//
//  ContentView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MapView(deviceData: DeviceData(
            symbol: "network",
            type: "ISP",
            name: "數據機",
            mac: "none",
            wanQuantity: 0,
            lanQuantity: 4,
            pingSupport: true
        ))
        
    }
    
}

func isDarkMode() -> Bool {
    // Get the current window scene and its color scheme
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return false
    }
    
    return windowScene.windows.first?.traitCollection.userInterfaceStyle == .dark
}

#Preview {
    ContentView()
}


