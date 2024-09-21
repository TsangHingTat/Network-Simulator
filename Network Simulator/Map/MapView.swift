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
                ScrollView(.horizontal, showsIndicators: false) {
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
            }
            .navigationTitle("網路建構器")
        }
        .navigationViewStyle(.stack)
    }

    /// Simulate DHCP-like IP assignment
    func dhcp() {
        print("DHCP Started")
        
        // Assign IP addresses starting from the root router
        assignIPsToDevices(deviceData, baseSubnet: "192.168", subnetLevel: 0)
    }
    
    /// Assign IP addresses to devices using the router's subnet range (DHCP-like logic)
    private func assignIPsToDevices(_ device: DeviceData, baseSubnet: String, subnetLevel: Int) {
        let subnetMask = "255.255.255.0" // Commonly used subnet mask for /24 networks
        var subnetIndex = subnetLevel // Tracks the current subnet index

        // Helper function to generate the next available IP for a device
        func getNextAvailableIP(baseSubnet: String, hostIndex: Int) -> String {
            return "\(baseSubnet).\(hostIndex)" // Generates a valid IP address in the current subnet
        }

        // Recursive function to assign IP addresses based on device type
        func assignIPsRecursively(_ devices: [DeviceData], baseSubnet: String, parentIPIndex: inout Int) {
            var currentHostIP = parentIPIndex // Start assigning IPs to devices from this point

            for device in devices {
                if device.type == "router" {
                    // Routers create new subnets
                    let routerSubnet = "192.168.\(subnetIndex)"
                    let routerIP = "\(routerSubnet).1" // Router gets .1 in its own subnet
                    ipaddress.append([device.mac, routerIP, subnetMask])
                    subnetIndex += 1 // Increment subnet index for the next router

                    // Recursively assign IPs to devices connected to the router using its new subnet
                    var newRouterHostIP = 2 // Reset for the new router subnet
                    assignIPsRecursively(device.children, baseSubnet: routerSubnet, parentIPIndex: &newRouterHostIP)
                } else if device.type == "switch" {
                    // Switches do not create a new subnet, they use the parent's subnet
                    let switchIP = getNextAvailableIP(baseSubnet: baseSubnet, hostIndex: currentHostIP)
                    ipaddress.append([device.mac, switchIP, subnetMask])
                    currentHostIP += 1 // Move to the next available IP

                    // Recursively assign IPs to devices connected to the switch, using the same subnet as the parent router
                    assignIPsRecursively(device.children, baseSubnet: baseSubnet, parentIPIndex: &currentHostIP)
                } else {
                    // Regular devices (e.g., PCs) get an IP in the parent's subnet
                    let deviceIP = getNextAvailableIP(baseSubnet: baseSubnet, hostIndex: currentHostIP)
                    ipaddress.append([device.mac, deviceIP, subnetMask])
                    currentHostIP += 1
                }
            }

            // Update parentIPIndex to reflect the next available IP for the parent subnet
            parentIPIndex = currentHostIP
        }

        // Start the recursive assignment from the root router using the base subnet
        let rootRouterSubnet = "192.168.\(subnetLevel)" // Define the base subnet for the root router
        let rootRouterIP = "\(rootRouterSubnet).1"
        ipaddress.append([device.mac, rootRouterIP, subnetMask]) // Assign IP to the root router

        var parentIPIndex = 2 // IPs for devices start from .2
        assignIPsRecursively(device.children, baseSubnet: rootRouterSubnet, parentIPIndex: &parentIPIndex)
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
    }
}
