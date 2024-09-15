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
            name: "互聯網服務供應商",
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
                            pingSupport: true,
                            children: [
                                DeviceData(
                                    symbol: "desktopcomputer",
                                    type: "computer",
                                    name: "電腦 1",
                                    mac: "00:00:00:00:00:04",
                                    wanQuantity: 0,
                                    lanQuantity: 1,
                                    pingSupport: true
                                ),
                                DeviceData(
                                    symbol: "tv",
                                    type: "tv",
                                    name: "電視 1",
                                    mac: "00:00:00:00:00:05",
                                    wanQuantity: 0,
                                    lanQuantity: 1,
                                    pingSupport: false
                                )
                            ]
                        ),
                        DeviceData(
                            symbol: "server.rack",
                            type: "switch",
                            name: "網絡交換機 2",
                            mac: "00:00:00:00:00:06",
                            wanQuantity: 0,
                            lanQuantity: 24,
                            pingSupport: true,
                            children: [
                                DeviceData(
                                    symbol: "fanblades",
                                    type: "fan",
                                    name: "智能風扇 1",
                                    mac: "00:00:00:00:00:07",
                                    wanQuantity: 0,
                                    lanQuantity: 1,
                                    pingSupport: false
                                ),
                                DeviceData(
                                    symbol: "fanblades",
                                    type: "fan",
                                    name: "智能風扇 2",
                                    mac: "00:00:00:00:00:08",
                                    wanQuantity: 0,
                                    lanQuantity: 1,
                                    pingSupport: false,
                                    children: [
                                        DeviceData(
                                            symbol: "tv",
                                            type: "tv",
                                            name: "電視 2",
                                            mac: "00:00:00:00:00:09",
                                            wanQuantity: 0,
                                            lanQuantity: 1,
                                            pingSupport: false
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "web",
                    name: "網頁伺服器",
                    mac: "00:00:00:00:00:0A",
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "vpn",
                    name: "VPN 伺服器",
                    mac: "00:00:00:00:00:0B",
                    wanQuantity: 1,
                    lanQuantity: 1,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "dns",
                    name: "DNS 伺服器",
                    mac: "00:00:00:00:00:0C",
                    wanQuantity: 1,
                    lanQuantity: 1,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "firewall",
                    name: "防火牆",
                    mac: "00:00:00:00:00:0D",
                    wanQuantity: 1,
                    lanQuantity: 1,
                    pingSupport: false
                )
            ]
        ))
        
    }
    
}


#Preview {
    ContentView()
}
