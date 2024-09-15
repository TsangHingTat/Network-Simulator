//
//  IPTools.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/13/24.
//

import Foundation

func isValidIP(_ ip: String) -> Bool {
    let parts = ip.split(separator: ".")
    guard parts.count == 4 else { return false }

    for part in parts {
        guard let number = Int(part), number >= 0 && number <= 255 else {
            return false
        }
    }
    return true
}

func isValidSubnetMask(_ mask: String) -> Bool {
    let validMasks = [
        "255.0.0.0", "255.255.0.0", "255.255.255.0", "255.255.255.128",
        "255.255.255.192", "255.255.255.224", "255.255.255.240",
        "255.255.255.248", "255.255.255.252", "255.255.255.254"
    ]
    return validMasks.contains(mask)
}

func pingable(deviceIp: String, pingIp: String) -> (Bool, Int) {
    return (true, 3)
}

func generateMACAddress(existingMACs: [String]) -> String {
    let characters = "0123456789ABCDEF"
    var macAddress: String

    repeat {
        macAddress = ""
        for _ in 0..<6 {
            if !macAddress.isEmpty {
                macAddress += ":"
            }
            for _ in 0..<2 {
                macAddress += String(characters.randomElement()!)
            }
        }
    } while existingMACs.contains(macAddress)

    return macAddress
}
