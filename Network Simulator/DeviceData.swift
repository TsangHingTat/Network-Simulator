//
//  DeviceDatas.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

class DeviceData: Identifiable, Codable {
    var id = UUID()
    var symbol: String
    var type: String
    var name: String
    var mac: String
    var wanQuantity: Int
    var lanQuantity: Int
    var pingSupport: Bool
    var children: [DeviceData]

    init(symbol: String, type: String, name: String, mac: String, wanQuantity: Int, lanQuantity: Int, pingSupport: Bool, children: [DeviceData] = []) {
        self.symbol = symbol
        self.type = type
        self.name = name
        self.mac = mac
        self.wanQuantity = wanQuantity
        self.lanQuantity = lanQuantity
        self.pingSupport = pingSupport
        self.children = children
    }

    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case type
        case name
        case mac
        case wanQuantity
        case lanQuantity
        case pingSupport
        case children
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        symbol = try container.decode(String.self, forKey: .symbol)
        type = try container.decode(String.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        mac = try container.decode(String.self, forKey: .mac)
        wanQuantity = try container.decode(Int.self, forKey: .wanQuantity)
        lanQuantity = try container.decode(Int.self, forKey: .lanQuantity)
        pingSupport = try container.decode(Bool.self, forKey: .pingSupport)
        children = try container.decodeIfPresent([DeviceData].self, forKey: .children) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(mac, forKey: .mac)
        try container.encode(wanQuantity, forKey: .wanQuantity)
        try container.encode(lanQuantity, forKey: .lanQuantity)
        try container.encode(pingSupport, forKey: .pingSupport)
        try container.encode(children, forKey: .children)
    }
}
