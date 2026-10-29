//
//  NetworkV4.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import Foundation

struct NetworkV4: Codable, Equatable, Hashable, Sendable {
    var dhcpEnabled: Bool = true
    var ipAddress: String = ""
    var subnetMask: String = "255.255.255.0"
    var gateway: String = ""
    var dns: String = "8.8.8.8"
    
    var showIPError: Bool = false
    var showSubnetMaskError: Bool = false
    var showGatewayError: Bool = false

    var isStaticConfigValid: Bool {
        guard !dhcpEnabled else { return true }
        guard isValidIP(ipAddress) else { return false }
        guard isValidSubnetMask(subnetMask) else { return false }
        if !gateway.isEmpty && !isValidIP(gateway) { return false }
        return true
    }
}
