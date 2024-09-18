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
    @State var ipaddress: [[String]] = [] // MAC to IP mapping

    var body: some View {
        NavigationView {
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
                        .onAppear {
                            dhcp() // Start DHCP logic on appearance
                            showMap.toggle()
                        }
                }
            }
            .navigationTitle("網路建構器")
        }
        .navigationViewStyle(.stack)
    }

    /// Simulate DHCP-like IP assignment
    func dhcp() {
        print("DHCP Started")
        
        // Assign IP addresses to all devices connected to the root router
        assignIPsToDevices(deviceData, baseSubnet: "192.168", subnetLevel: 0)
    }
    
    /// Assign IP addresses to devices using the router's subnet range (DHCP-like logic)
    private func assignIPsToDevices(_ device: DeviceData, baseSubnet: String, subnetLevel: Int) {
        var currentHostIP = 2 // Start IP allocation at .2 (router is .1)
        let subnetMask = "255.255.255.0" // Common subnet mask for /24 networks
        
        func getNextAvailableIP(for level: Int) -> String {
            let ip = "\(baseSubnet).\(level).\(currentHostIP)"
            currentHostIP += 1
            return ip
        }
        
        // Helper function to assign IPs recursively
        func assignIPsRecursively(_ devices: [DeviceData], baseSubnet: String, subnetLevel: Int) {
            for device in devices {
                if device.type == "switch" {
                    // Assign IP to the switch itself
                    let switchIP = getNextAvailableIP(for: subnetLevel)
                    ipaddress.append([device.mac, switchIP, subnetMask])
                    
                    // Recursively assign IPs to devices connected to this switch
                    assignIPsRecursively(device.children, baseSubnet: baseSubnet, subnetLevel: subnetLevel)
                } else if device.type == "router" {
                    // Subrouter logic: Assign a subnet for this subrouter
                    let newSubnetLevel = subnetLevel + 1
                    let newSubnet = "\(baseSubnet).\(newSubnetLevel)"
                    
                    // Assign IP to the subrouter itself
                    let subrouterIP = getNextAvailableIP(for: newSubnetLevel)
                    ipaddress.append([device.mac, subrouterIP, subnetMask])
                    
                    // Recursively assign IPs to devices connected to this subrouter
                    assignIPsRecursively(device.children, baseSubnet: newSubnet, subnetLevel: newSubnetLevel)
                } else {
                    // Assign IP to the non-switch device
                    var ip: String
                    repeat {
                        ip = getNextAvailableIP(for: subnetLevel)
                    } while ipaddress.contains(where: { $0[1] == ip }) // Ensure unique IP in subnet
                    
                    // Assign new IP to the device
                    ipaddress.append([device.mac, ip, subnetMask])
                }
            }
        }
        
        // Assign IPs starting from router
        let routerIP = "\(baseSubnet).\(subnetLevel).1"
        ipaddress.append([device.mac, routerIP, subnetMask]) // Assign IP to the router
        
        // Assign IPs to all devices connected to the router
        assignIPsRecursively(device.children, baseSubnet: baseSubnet, subnetLevel: subnetLevel)
    }

    /// Updates the `ipaddress` array with new IPs, ensuring no duplicates
    private func updateIPAddress(with newIPs: [[String]]) {
        // Remove outdated entries for the same MAC addresses
        for newIP in newIPs {
            if let index = ipaddress.firstIndex(where: { $0[0] == newIP[0] }) {
                ipaddress.remove(at: index)
            }
        }
        
        // Add the new IPs to the list
        ipaddress.append(contentsOf: newIPs)
        print("Updated IPs: \(ipaddress)")
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
                symbol: "switch",
                type: "switch",
                name: "Switch 1",
                mac: "00:00:00:00:00:01",
                wanQuantity: 0,
                lanQuantity: 4,
                pingSupport: false,
                children: [
                    DeviceData(
                        symbol: "router",
                        type: "router",
                        name: "Subrouter 1",
                        mac: "00:00:00:00:00:02",
                        wanQuantity: 1,
                        lanQuantity: 4,
                        pingSupport: true,
                        children: [
                            DeviceData(
                                symbol: "router",
                                type: "router",
                                name: "Sub-Subrouter 1",
                                mac: "00:00:00:00:00:03",
                                wanQuantity: 1,
                                lanQuantity: 4,
                                pingSupport: true,
                                children: [
                                    DeviceData(
                                        symbol: "pc",
                                        type: "pc",
                                        name: "PC 1",
                                        mac: "00:00:00:00:00:04",
                                        wanQuantity: 0,
                                        lanQuantity: 0,
                                        pingSupport: true
                                    )
                                ]
                            )
                        ]
                    )
                ]
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
