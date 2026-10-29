//
//  DeviceData.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI
import Combine

class DeviceData: Identifiable, Codable, ObservableObject, Equatable {
    @Published var id: UUID = UUID()
    @Published var symbol: String
    @Published var type: String
    @Published var name: String
    @Published var mac: String
    @Published var wanQuantity: Int
    @Published var lanQuantity: Int
    @Published var pingSupport: Bool
    @Published var children: [DeviceData] {
        didSet {
            for child in children {
                child.parent = self
            }
        }
    }
    
    @Published var isPoweredOn: Bool = true
    @Published var networkV4: NetworkV4 = NetworkV4()
    @Published var assignedIP: String = ""
    @Published var assignedSubnetMask: String = "255.255.255.0"
    @Published var assignedGateway: String = ""
    @Published var connectionType: ConnectionType = .noConnection

    weak var parent: DeviceData?

    init(
        id: UUID = UUID(),
        symbol: String,
        type: String,
        name: String,
        mac: String,
        wanQuantity: Int,
        lanQuantity: Int,
        pingSupport: Bool,
        children: [DeviceData] = [],
        parent: DeviceData? = nil,
        isPoweredOn: Bool = true,
        networkV4: NetworkV4 = NetworkV4(),
        assignedIP: String = "",
        assignedSubnetMask: String = "255.255.255.0",
        assignedGateway: String = "",
        connectionType: ConnectionType = .noConnection
    ) {
        self.id = id
        self.symbol = symbol
        self.type = type
        self.name = name
        self.mac = mac
        self.wanQuantity = wanQuantity
        self.lanQuantity = lanQuantity
        self.pingSupport = pingSupport
        self.children = children
        self.parent = parent
        self.isPoweredOn = isPoweredOn
        self.networkV4 = networkV4
        self.assignedIP = assignedIP
        self.assignedSubnetMask = assignedSubnetMask
        self.assignedGateway = assignedGateway
        self.connectionType = connectionType

        for child in children {
            child.parent = self
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, symbol, type, name, mac, wanQuantity, lanQuantity, pingSupport
        case children, isPoweredOn, networkV4, assignedIP, assignedSubnetMask, assignedGateway, connectionType
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.mac = try container.decode(String.self, forKey: .mac)
        self.wanQuantity = try container.decode(Int.self, forKey: .wanQuantity)
        self.lanQuantity = try container.decode(Int.self, forKey: .lanQuantity)
        self.pingSupport = try container.decode(Bool.self, forKey: .pingSupport)
        self.isPoweredOn = try container.decodeIfPresent(Bool.self, forKey: .isPoweredOn) ?? true
        self.networkV4 = try container.decodeIfPresent(NetworkV4.self, forKey: .networkV4) ?? NetworkV4()
        self.assignedIP = try container.decodeIfPresent(String.self, forKey: .assignedIP) ?? ""
        self.assignedSubnetMask = try container.decodeIfPresent(String.self, forKey: .assignedSubnetMask) ?? "255.255.255.0"
        self.assignedGateway = try container.decodeIfPresent(String.self, forKey: .assignedGateway) ?? ""
        self.connectionType = try container.decodeIfPresent(ConnectionType.self, forKey: .connectionType) ?? .noConnection
        let decodedChildren = try container.decodeIfPresent([DeviceData].self, forKey: .children) ?? []
        self.children = decodedChildren

        for child in decodedChildren {
            child.parent = self
        }
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
        try container.encode(isPoweredOn, forKey: .isPoweredOn)
        try container.encode(networkV4, forKey: .networkV4)
        try container.encode(assignedIP, forKey: .assignedIP)
        try container.encode(assignedSubnetMask, forKey: .assignedSubnetMask)
        try container.encode(assignedGateway, forKey: .assignedGateway)
        try container.encode(connectionType, forKey: .connectionType)
        try container.encode(children, forKey: .children)
    }

    static func == (lhs: DeviceData, rhs: DeviceData) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.mac == rhs.mac &&
               lhs.isPoweredOn == rhs.isPoweredOn &&
               lhs.assignedIP == rhs.assignedIP &&
               lhs.children == rhs.children
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

    // MARK: - Tree Helper Methods
    func allDevices() -> [DeviceData] {
        var list: [DeviceData] = [self]
        for child in children {
            list.append(contentsOf: child.allDevices())
        }
        return list
    }

    func allDescendants() -> [DeviceData] {
        var list: [DeviceData] = []
        for child in children {
            list.append(child)
            list.append(contentsOf: child.allDescendants())
        }
        return list
    }

    func allMACs() -> [String] {
        return allDevices().compactMap { $0.mac == "none" ? nil : $0.mac }
    }

    func findDevice(byId targetId: UUID) -> DeviceData? {
        if self.id == targetId { return self }
        for child in children {
            if let found = child.findDevice(byId: targetId) {
                return found
            }
        }
        return nil
    }

    func findDevice(byMac targetMac: String) -> DeviceData? {
        if self.mac.caseInsensitiveCompare(targetMac) == .orderedSame { return self }
        for child in children {
            if let found = child.findDevice(byMac: targetMac) {
                return found
            }
        }
        return nil
    }

    func findDevice(byIp targetIp: String) -> DeviceData? {
        if self.effectiveIP == targetIp { return self }
        for child in children {
            if let found = child.findDevice(byIp: targetIp) {
                return found
            }
        }
        return nil
    }

    func findParent(of childDevice: DeviceData) -> DeviceData? {
        if children.contains(where: { $0.id == childDevice.id }) {
            return self
        }
        for child in children {
            if let found = child.findParent(of: childDevice) {
                return found
            }
        }
        return nil
    }

    var effectiveIP: String {
        if !networkV4.dhcpEnabled && isValidIP(networkV4.ipAddress) {
            return networkV4.ipAddress
        }
        return assignedIP
    }

    var effectiveSubnetMask: String {
        if !networkV4.dhcpEnabled && isValidSubnetMask(networkV4.subnetMask) {
            return networkV4.subnetMask
        }
        return assignedSubnetMask.isEmpty ? "255.255.255.0" : assignedSubnetMask
    }

    var effectiveGateway: String {
        if !networkV4.dhcpEnabled && isValidIP(networkV4.gateway) {
            return networkV4.gateway
        }
        return assignedGateway
    }

    func canAddChild() -> Bool {
        return children.count < lanQuantity
    }

    func addChild(_ child: DeviceData) {
        child.parent = self
        children.append(child)
    }

    @discardableResult
    func removeChild(id: UUID) -> Bool {
        if let idx = children.firstIndex(where: { $0.id == id }) {
            children.remove(at: idx)
            return true
        }
        for child in children {
            if child.removeChild(id: id) {
                return true
            }
        }
        return false
    }

    // Checks if this node and all of its ancestors are powered on
    func isOnlineInNetwork() -> Bool {
        guard isPoweredOn else { return false }
        var current = parent
        while let p = current {
            if !p.isPoweredOn { return false }
            current = p.parent
        }
        return true
    }

    // MARK: - Network DHCP and Topology Simulator
    func recalculateNetwork() {
        var subnetIndex = 0
        let defaultMask = "255.255.255.0"

        // Root is modem / ISP gateway
        if self.type.lowercased() == "isp" || self.mac == "none" {
            self.assignedIP = "203.0.113.1" // Public WAN IP for ISP modem
            self.assignedSubnetMask = defaultMask
            self.assignedGateway = "203.0.113.254"
            self.connectionType = self.isPoweredOn ? .internetConnection : .offline
        } else if self.assignedIP.isEmpty {
            self.assignedIP = "192.168.0.1"
            self.assignedSubnetMask = defaultMask
            self.assignedGateway = ""
            self.connectionType = self.isPoweredOn ? .internetConnection : .offline
        }

        func processChildren(of device: DeviceData, currentSubnet: String, gatewayIP: String, hasInternet: Bool) {
            var hostCounter = 2

            for child in device.children {
                let isChildOnline = hasInternet && child.isPoweredOn

                if child.type.lowercased() == "router" {
                    // Router creates a new local subnet
                    subnetIndex += 1
                    let newSubnet = "192.168.\(subnetIndex)"
                    let routerLanIP = "\(newSubnet).1"
                    let routerWanIP = "\(currentSubnet).\(hostCounter)"
                    hostCounter += 1

                    child.assignedIP = routerLanIP
                    child.assignedSubnetMask = defaultMask
                    child.assignedGateway = gatewayIP

                    child.connectionType = !child.isPoweredOn ? .offline : (isChildOnline ? .internetConnection : .localConnection)

                    processChildren(of: child, currentSubnet: newSubnet, gatewayIP: routerLanIP, hasInternet: isChildOnline)
                } else if child.type.lowercased() == "switch" {
                    // Switch extends current subnet
                    let switchIP = "\(currentSubnet).\(hostCounter)"
                    hostCounter += 1

                    child.assignedIP = switchIP
                    child.assignedSubnetMask = defaultMask
                    child.assignedGateway = gatewayIP
                    child.connectionType = !child.isPoweredOn ? .offline : (isChildOnline ? .internetConnection : .localConnection)

                    // Switch passes the same subnet down to children
                    processChildren(of: child, currentSubnet: currentSubnet, gatewayIP: gatewayIP, hasInternet: isChildOnline)
                } else if child.type.lowercased() == "firewall" {
                    let firewallIP = "\(currentSubnet).\(hostCounter)"
                    hostCounter += 1

                    child.assignedIP = firewallIP
                    child.assignedSubnetMask = defaultMask
                    child.assignedGateway = gatewayIP
                    child.connectionType = !child.isPoweredOn ? .offline : .restrictedConnection

                    processChildren(of: child, currentSubnet: currentSubnet, gatewayIP: gatewayIP, hasInternet: false)
                } else {
                    // End devices (PC, Server, IoT)
                    if child.networkV4.dhcpEnabled {
                        child.assignedIP = "\(currentSubnet).\(hostCounter)"
                        child.assignedSubnetMask = defaultMask
                        child.assignedGateway = gatewayIP
                        hostCounter += 1
                    } else {
                        // Static IP kept as is
                        if child.networkV4.gateway.isEmpty {
                            child.networkV4.gateway = gatewayIP
                        }
                    }

                    if !child.isPoweredOn {
                        child.connectionType = .offline
                    } else if !isChildOnline {
                        child.connectionType = (child.parent?.isPoweredOn == true) ? .localConnection : .noConnection
                    } else {
                        child.connectionType = .internetConnection
                    }
                }
            }
        }

        let isRootOnline = self.isPoweredOn
        processChildren(of: self, currentSubnet: "192.168.0", gatewayIP: self.effectiveIP, hasInternet: isRootOnline)
    }

    // MARK: - Real Routing & Ping Simulation
    func simulatePing(to targetIP: String) -> (success: Bool, latencyMs: Double, hops: Int, message: String) {
        guard self.isPoweredOn else {
            return (false, 0, 0, "本設備已關閉電源")
        }
        guard isOnlineInNetwork() else {
            return (false, 0, 0, "上層網絡設備已斷電或斷開連接")
        }

        let trimmedTarget = targetIP.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidIP(trimmedTarget) else {
            return (false, 0, 0, "無效的 IP 地址: \(trimmedTarget)")
        }

        let myIP = self.effectiveIP
        guard !myIP.isEmpty else {
            return (false, 0, 0, "本機未取得有效 IP 地址")
        }

        // Ping self / loopback
        if trimmedTarget == myIP || trimmedTarget == "127.0.0.1" {
            return (true, 0.12, 0, "64 bytes from \(trimmedTarget): icmp_seq=1 ttl=64 time=0.12 ms")
        }

        // Find root to search entire network
        var rootNode = self
        while let p = rootNode.parent {
            rootNode = p
        }

        // Search for target device in topology
        let targetDevice = rootNode.findDevice(byIp: trimmedTarget)

        // If target is external Internet (e.g. 8.8.8.8, 1.1.1.1, etc.)
        if targetDevice == nil {
            if IPv4Address(string: trimmedTarget)?.isPrivate == false {
                // Must have internet connection to reach public internet
                if self.connectionType == .internetConnection {
                    let latency = Double.random(in: 15.0...35.0)
                    return (true, latency, 3, "64 bytes from \(trimmedTarget): icmp_seq=1 ttl=56 time=\(String(format: "%.2f", latency)) ms")
                } else {
                    return (false, 0, 0, "Request timeout for icmp_seq 1 (無外網路由)")
                }
            } else {
                return (false, 0, 0, "Destination Host Unreachable (未在局域網中找到主機)")
            }
        }

        guard let target = targetDevice else {
            return (false, 0, 0, "Request timeout for icmp_seq 1")
        }

        // Target must be powered on and online
        guard target.isPoweredOn && target.isOnlineInNetwork() else {
            return (false, 0, 0, "Request timeout for icmp_seq 1 (目標設備已關機或離線)")
        }

        // Check if target supports ping (e.g. firewall or TV with pingSupport == false)
        guard target.pingSupport else {
            return (false, 0, 0, "Request timeout for icmp_seq 1 (目標設備阻擋 ICMP/Ping)")
        }

        // Check subnet and routing
        guard let myAddr = IPv4Address(string: myIP),
              let maskAddr = IPv4Address(string: effectiveSubnetMask),
              let targetAddr = IPv4Address(string: trimmedTarget) else {
            return (false, 0, 0, "IP 解析錯誤")
        }

        let isSameSubnet = myAddr.isSameSubnet(as: targetAddr, mask: maskAddr)

        if isSameSubnet {
            // Local direct ping via switch / LAN
            let latency = Double.random(in: 0.3...1.8)
            return (true, latency, 1, "64 bytes from \(trimmedTarget): icmp_seq=1 ttl=64 time=\(String(format: "%.2f", latency)) ms")
        } else {
            // Routed ping across routers
            guard !effectiveGateway.isEmpty else {
                return (false, 0, 0, "No route to host (缺少預設閘道)")
            }
            let latency = Double.random(in: 1.5...4.5)
            return (true, latency, 2, "64 bytes from \(trimmedTarget): icmp_seq=1 ttl=63 time=\(String(format: "%.2f", latency)) ms")
        }
    }
}

extension DeviceData {
    func printDescription(indentLevel: Int = 0) {
        let indent = String(repeating: "  ", count: indentLevel)
        print("\(indent)Device: \(name) [\(type)] IP: \(effectiveIP) MAC: \(mac) Power: \(isPoweredOn)")
        for child in children {
            child.printDescription(indentLevel: indentLevel + 1)
        }
    }
}
