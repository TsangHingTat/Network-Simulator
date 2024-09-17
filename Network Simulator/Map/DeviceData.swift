//
//  DeviceData.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

import SwiftUI
import Combine

class DeviceData: Identifiable, Codable, ObservableObject, Equatable {
    @Published var id = UUID()
    @Published var symbol: String
    @Published var type: String
    @Published var name: String
    @Published var mac: String
    @Published var wanQuantity: Int
    @Published var lanQuantity: Int
    @Published var pingSupport: Bool
    @Published var children: [DeviceData]
    
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
    
    func makeIterator() -> AnyIterator<DeviceData> {
        var stack = [self]
        return AnyIterator {
            while !stack.isEmpty {
                let current = stack.removeLast()
                stack.append(contentsOf: current.children)
                return current
            }
            return nil
        }
    }
    
    static func == (lhs: DeviceData, rhs: DeviceData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.symbol == rhs.symbol &&
        lhs.type == rhs.type &&
        lhs.name == rhs.name &&
        lhs.mac == rhs.mac &&
        lhs.wanQuantity == rhs.wanQuantity &&
        lhs.lanQuantity == rhs.lanQuantity &&
        lhs.pingSupport == rhs.pingSupport &&
        lhs.children == rhs.children
    }
}

extension DeviceData {
    func printDescription(indentLevel: Int = 0) {
        // Create an indentation string for formatting
        let indent = String(repeating: "  ", count: indentLevel)
        
        // Print the current device's details
        print("\(indent)Device ID: \(id)")
        print("\(indent)Symbol: \(symbol)")
        print("\(indent)Type: \(type)")
        print("\(indent)Name: \(name)")
        print("\(indent)MAC Address: \(mac)")
        print("\(indent)WAN Quantity: \(wanQuantity)")
        print("\(indent)LAN Quantity: \(lanQuantity)")
        print("\(indent)Ping Support: \(pingSupport)")
        
        // Recursively print children devices
        if !(children.count == 0) {
            print("\(indent)Children:")
            for child in children {
                child.printDescription(indentLevel: indentLevel + 1)
            }
        }
    }
}
