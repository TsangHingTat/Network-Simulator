//
//  DevicesView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct DeviceView: View {
    @Binding var device: DeviceData
    
    var isChild = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SymbolView(symbol: device.symbol, name: device.name, mac: device.mac, isChild: isChild)
                .padding(.horizontal)
            
            if !device.children.isEmpty {
                ForEach($device.children) { child in
                    HStack {
                        Spacer()
                            .frame(width: 50)
                        DeviceView(
                            device: child,
                            isChild: true
                        )
                    }
                    
                }
            }
        }
    }
}


#Preview {
    DeviceView(device: .constant(
        DeviceData(
            symbol: "network",
            type: "ISP",
            name: "互聯網",
            mac: "none",
            wanQuantity: 1,
            lanQuantity: 0,
            pingSupport: true,
            children: [
                DeviceData(
                    symbol: "wifi.router",
                    type: "router",
                    name: "WiFi 路由器",
                    mac: "00:00:00:00:00:02",
                    wanQuantity: 1,
                    lanQuantity: 4,
                    pingSupport: true,
                    children: [
                        DeviceData(
                            symbol: "server.rack",
                            type: "switch",
                            name: "網絡交換機 1",
                            mac: "00:00:00:00:00:03",
                            wanQuantity: 0,
                            lanQuantity: 24,
                            pingSupport: true
                            
                        )
                    ]
                )
            ]
            
        )
    )
    )
}
