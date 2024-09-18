//
//  MapView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct MapView: View {
    @State var deviceData: DeviceData
    @State var showMap = false
    @State var ipaddress: [[String]] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView {
                    if showMap {
                        DeviceView(
                            device: $deviceData,
                            mainPastData: $deviceData,
                            showMap: $showMap,
                            ipaddress: $ipaddress
                        )
                    } else {
                        Text("Loading...")
                            .onAppear() {
                                dhcp()
                                showMap.toggle()
                            }
                    }
                }
            }
            .navigationTitle("網路建構器")

        }
        .navigationViewStyle(.stack)
    }
    
    func dhcp() -> Void {
        print("DHCP Started")
        
        // Find routers
        var temp0: [String] = []
        func findRouter(_ input: DeviceData) -> Void {
            for i in input.children {
                if i.type == "router" {
                    temp0.append(i.mac)
                }
            }
        }
        print("Found \(temp0.count) router(s).")
        findRouter(deviceData)
        var foundedInt = 0
        var temp1: [[String]] = []
        func runDhcp() -> Void {
            for i in deviceData.children {
                for j in temp0 {
                    if i.mac == j {
                        // Each router
                        let providedSubNetMask = "255.255.255.0"
                        let ipAddress = "192.168.1.1"
                        
                        if let (firstIp, lastIp) = getIpRange(ipAddress: ipAddress, subnetMask: providedSubNetMask) {
                            print("First usable IP: \(firstIp)")
                            print("Last usable IP: \(lastIp)")
                            temp1.append([i.mac, firstIp, providedSubNetMask])
                            foundedInt += 1
                        } else {
                            print("Invalid IP address or subnet mask")
                        }
                        
                        
                    }
                }
            }
        }
        runDhcp()
        
        if temp1.count != 0 {
            for i in 0...temp1.count-1 {
                if ipaddress.count != 0 {
                    for j in 0...ipaddress.count-1 {
                        if temp1[i][0] == ipaddress[j][0] {
                            ipaddress.remove(at: j)
                        }
                    }
                }
            }
        }
        
        for i in temp1 {
            ipaddress.append(i)
            print("Add iP \(i)")
        }
        
    }

    func ipStringToOctets(_ ipString: String) -> [UInt8] {
        return ipString.split(separator: ".").compactMap { UInt8($0) }
    }

    func octetsToIpString(_ octets: [UInt8]) -> String {
        return octets.map { String($0) }.joined(separator: ".")
    }

    func bitwiseNot(_ value: UInt8) -> UInt8 {
        return ~value
    }

    func getNetworkAddress(ipAddress: String, subnetMask: String) -> [UInt8]? {
        let ipOctets = ipStringToOctets(ipAddress)
        let subnetOctets = ipStringToOctets(subnetMask)
        
        guard ipOctets.count == 4, subnetOctets.count == 4 else {
            return nil // Invalid input
        }
        
        let networkOctets = zip(ipOctets, subnetOctets).map { $0 & $1 }
        return networkOctets
    }

    func getBroadcastAddress(networkAddress: [UInt8], subnetMask: String) -> [UInt8]? {
        let subnetOctets = ipStringToOctets(subnetMask)
        
        guard subnetOctets.count == 4 else {
            return nil // Invalid subnet mask
        }
        
        let invertedSubnetOctets = subnetOctets.map { bitwiseNot($0) }
        let broadcastOctets = zip(networkAddress, invertedSubnetOctets).map { $0 | $1 }
        
        return broadcastOctets
    }

    func getIpRange(ipAddress: String, subnetMask: String) -> (String, String)? {
        guard let networkAddress = getNetworkAddress(ipAddress: ipAddress, subnetMask: subnetMask),
              let broadcastAddress = getBroadcastAddress(networkAddress: networkAddress, subnetMask: subnetMask) else {
            return nil
        }
        
        // First usable IP (network address + 1)
        var firstIp = networkAddress
        firstIp[3] += 1
        
        // Last usable IP (broadcast address - 1)
        var lastIp = broadcastAddress
        lastIp[3] -= 1
        
        // Convert to strings
        let firstIpString = octetsToIpString(firstIp)
        let lastIpString = octetsToIpString(lastIp)
        
        return (firstIpString, lastIpString)
    }
    
}







struct MapView_Previews: PreviewProvider {
    @State static var mockDeviceData = DeviceData(
        symbol: "wifi.router",
        type: "router",
        name: "Router",
        mac: "00:00:00:00:00:00",
        wanQuantity: 1,
        lanQuantity: 4,
        pingSupport: true,
        children: [
            DeviceData(
                symbol: "pc",
                type: "pc",
                name: "PC",
                mac: "00:00:00:00:00:01",
                wanQuantity: 0,
                lanQuantity: 0,
                pingSupport: true
            )
        ]
    )
    
    @State static var showMap = true

    static var previews: some View {
        MapView(deviceData: mockDeviceData, showMap: showMap)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
