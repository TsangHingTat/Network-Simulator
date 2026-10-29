//
//  DeviceInfo.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

enum DeviceCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case all = "全部"
    case network = "網絡設備"
    case server = "伺服器"
    case endpoint = "終端設備"
    case iot = "智能家居"

    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .network: return "network"
        case .server: return "server.rack"
        case .endpoint: return "desktopcomputer"
        case .iot: return "homekit"
        }
    }
}

struct DeviceInfo: Codable, Hashable, Identifiable, Sendable {
    var id: String { type }
    let name: String
    let icon: String
    let type: String
    let wanQuantity: Int
    let lanQuantity: Int
    let pingSupport: Bool
    var category: DeviceCategory {
        switch type {
        case "router", "switch", "firewall":
            return .network
        case "web", "vpn", "dns":
            return .server
        case "computer":
            return .endpoint
        case "tv", "fan":
            return .iot
        default:
            return .endpoint
        }
    }
}

private let fallbackDevices: [DeviceInfo] = [
    DeviceInfo(name: "WiFi 路由器", icon: "wifi.router", type: "router", wanQuantity: 1, lanQuantity: 4, pingSupport: true),
    DeviceInfo(name: "網絡交換機", icon: "server.rack", type: "switch", wanQuantity: 0, lanQuantity: 24, pingSupport: true),
    DeviceInfo(name: "防火牆", icon: "lock.shield", type: "firewall", wanQuantity: 1, lanQuantity: 1, pingSupport: false),
    DeviceInfo(name: "電腦", icon: "desktopcomputer", type: "computer", wanQuantity: 1, lanQuantity: 0, pingSupport: true),
    DeviceInfo(name: "網頁伺服器", icon: "server.rack", type: "web", wanQuantity: 1, lanQuantity: 0, pingSupport: true),
    DeviceInfo(name: "VPN 伺服器", icon: "server.rack", type: "vpn", wanQuantity: 1, lanQuantity: 1, pingSupport: true),
    DeviceInfo(name: "DNS 伺服器", icon: "server.rack", type: "dns", wanQuantity: 1, lanQuantity: 1, pingSupport: true),
    DeviceInfo(name: "電視", icon: "tv", type: "tv", wanQuantity: 1, lanQuantity: 0, pingSupport: false),
    DeviceInfo(name: "智能風扇", icon: "fanblades", type: "fan", wanQuantity: 1, lanQuantity: 0, pingSupport: false)
]

func loadSymbolInfos() -> [DeviceInfo] {
    guard let url = Bundle.main.url(forResource: "devices", withExtension: "json") else {
        return fallbackDevices
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([DeviceInfo].self, from: data)
    } catch {
        return fallbackDevices
    }
}
