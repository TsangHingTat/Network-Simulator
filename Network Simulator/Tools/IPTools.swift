//
//  IPTools.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/13/24.
//

import Foundation

// MARK: - IPv4 Address Representation
struct IPv4Address: Hashable, Equatable, Comparable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UInt32

    var octets: (UInt8, UInt8, UInt8, UInt8) {
        let b0 = UInt8((rawValue >> 24) & 0xFF)
        let b1 = UInt8((rawValue >> 16) & 0xFF)
        let b2 = UInt8((rawValue >> 8) & 0xFF)
        let b3 = UInt8(rawValue & 0xFF)
        return (b0, b1, b2, b3)
    }

    var description: String {
        let o = octets
        return "\(o.0).\(o.1).\(o.2).\(o.3)"
    }

    init?(string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 4 else { return nil }

        var octetValues: [UInt32] = []
        for part in parts {
            guard let val = UInt32(part), val <= 255 else { return nil }
            octetValues.append(val)
        }

        self.rawValue = (octetValues[0] << 24) | (octetValues[1] << 16) | (octetValues[2] << 8) | octetValues[3]
    }

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    init(octets: (UInt8, UInt8, UInt8, UInt8)) {
        self.rawValue = (UInt32(octets.0) << 24) | (UInt32(octets.1) << 16) | (UInt32(octets.2) << 8) | UInt32(octets.3)
    }

    static func < (lhs: IPv4Address, rhs: IPv4Address) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    func networkAddress(with mask: IPv4Address) -> IPv4Address {
        return IPv4Address(rawValue: self.rawValue & mask.rawValue)
    }

    func broadcastAddress(with mask: IPv4Address) -> IPv4Address {
        return IPv4Address(rawValue: (self.rawValue & mask.rawValue) | ~mask.rawValue)
    }

    func isSameSubnet(as other: IPv4Address, mask: IPv4Address) -> Bool {
        return self.networkAddress(with: mask) == other.networkAddress(with: mask)
    }

    var isPrivate: Bool {
        let o = octets
        if o.0 == 10 { return true }
        if o.0 == 172 && (o.1 >= 16 && o.1 <= 31) { return true }
        if o.0 == 192 && o.1 == 168 { return true }
        return false
    }

    var isLoopback: Bool {
        return octets.0 == 127
    }

    var isLinkLocal: Bool {
        return octets.0 == 169 && octets.1 == 254
    }

    var isMulticast: Bool {
        return octets.0 >= 224 && octets.0 <= 239
    }
}

// MARK: - Subnet Mask
struct SubnetMask: Hashable, Equatable, Sendable {
    static let defaultMask = "255.255.255.0"
    
    static let standardMasks: [(cidr: Int, mask: String)] = [
        (8, "255.0.0.0"),
        (16, "255.255.0.0"),
        (24, "255.255.255.0"),
        (25, "255.255.255.128"),
        (26, "255.255.255.192"),
        (27, "255.255.255.224"),
        (28, "255.255.255.240"),
        (29, "255.255.255.248"),
        (30, "255.255.255.252")
    ]
}

// MARK: - Validation Functions
func isValidIP(_ ip: String) -> Bool {
    return IPv4Address(string: ip) != nil
}

func isValidSubnetMask(_ mask: String) -> Bool {
    guard let maskIP = IPv4Address(string: mask) else { return false }
    let raw = maskIP.rawValue
    guard raw != 0 else { return false }
    let inverted = ~raw
    return (inverted & (inverted + 1)) == 0
}

// MARK: - MAC Address Generation
func generateMACAddress(existingMACs: [String] = []) -> String {
    let characters = Array("0123456789ABCDEF")
    let existingSet = Set(existingMACs.map { $0.uppercased() })

    for _ in 0..<100 {
        var segments: [String] = []
        for i in 0..<6 {
            if i == 0 {
                // Locally administered unicast MAC (second least significant bit is 1, LSB is 0)
                let firstNibble = characters.randomElement() ?? "0"
                let secondNibble = ["2", "6", "A", "E"].randomElement() ?? "2"
                segments.append("\(firstNibble)\(secondNibble)")
            } else {
                let firstNibble = characters.randomElement() ?? "0"
                let secondNibble = characters.randomElement() ?? "0"
                segments.append("\(firstNibble)\(secondNibble)")
            }
        }
        let candidate = segments.joined(separator: ":")
        if !existingSet.contains(candidate) {
            return candidate
        }
    }

    return "02:00:00:\(String(format: "%02X:%02X:%02X", Int.random(in: 0...255), Int.random(in: 0...255), Int.random(in: 0...255)))"
}

func generateRandomIPAddress() -> String {
    let octet1 = Int.random(in: 1...223)
    let octet2 = Int.random(in: 0...255)
    let octet3 = Int.random(in: 0...255)
    let octet4 = Int.random(in: 1...254)
    return "\(octet1).\(octet2).\(octet3).\(octet4)"
}
