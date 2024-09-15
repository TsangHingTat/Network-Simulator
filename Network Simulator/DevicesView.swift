//
//  DevicesView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct DeviceView: View {
    @Binding var device: DeviceData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SymbolView(symbol: device.symbol, name: device.name, mac: device.mac)
                .padding(.horizontal)
            
            if !device.children.isEmpty {
                ForEach($device.children) { child in
                    DeviceView(
                        device: child
                    )
                    .padding(.leading, 50) // Indent children
                }
            }
        }
    }
}
