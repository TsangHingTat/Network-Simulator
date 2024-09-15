//
//  NetworkV1.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import Foundation

struct NetworkV1 {
    var dhcpEnabled: Bool = true
    var ipAddress: String = ""
    var subnetMask: String = ""
    var showIPError: Bool = false
    var showSubnetMaskError: Bool = false
}
