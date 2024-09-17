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
            name: "互聯網",
            mac: "none",
            wanQuantity: 0,
            lanQuantity: 1,
            pingSupport: true
        ))

    }
    
}


#Preview {
    ContentView()
}


