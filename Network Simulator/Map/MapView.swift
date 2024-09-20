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
        let subnetMask = "255.255.255.0" // Common subnet mask for /24 networks
        var subnetIndex = subnetLevel // Keep track of the current subnet index

        // Helper function to generate IP for devices
        func getNextAvailableIP(baseSubnet: String, hostIndex: Int) -> String {
            return "\(baseSubnet).\(hostIndex)" // Generate a valid IP in the current subnet
        }
        
        // Recursive function to assign IPs, ensuring switches use the parent router's subnet
        func assignIPsRecursively(_ devices: [DeviceData], baseSubnet: String) {
            var currentHostIP = 2 // Start IP allocation at .2 for devices (excluding .1 for routers)

            for device in devices {
                if device.type == "router" {
                    // Routers create new subnets
                    let routerSubnet = "192.168.\(subnetIndex)"
                    let routerIP = "\(routerSubnet).1" // Router gets the .1 IP in its own subnet
                    ipaddress.append([device.mac, routerIP, subnetMask])
                    subnetIndex += 1 // Increment subnet for the next router
                    
                    // Recursively assign IPs to devices connected to this router (new subnet)
                    assignIPsRecursively(device.children, baseSubnet: routerSubnet)
                } else if device.type == "switch" {
                    // Switches do not create a new subnet, they use the parent's subnet
                    let switchIP = getNextAvailableIP(baseSubnet: baseSubnet, hostIndex: currentHostIP)
                    ipaddress.append([device.mac, switchIP, subnetMask])
                    currentHostIP += 1 // Move to the next available IP
                    
                    // Assign IPs to devices connected to this switch (same subnet as parent router)
                    assignIPsRecursively(device.children, baseSubnet: baseSubnet)
                } else {
                    // Regular devices (e.g., PCs) get IPs in the parent's subnet
                    let deviceIP = getNextAvailableIP(baseSubnet: baseSubnet, hostIndex: currentHostIP)
                    ipaddress.append([device.mac, deviceIP, subnetMask])
                    currentHostIP += 1
                }
            }
        }
        
        // Assign root router to the main subnet (192.168.0.x) and start recursive assignment
        let rootRouterSubnet = "192.168.\(subnetLevel)" // Set the base subnet for the root router
        let rootRouterIP = "\(rootRouterSubnet).1"
        ipaddress.append([device.mac, rootRouterIP, subnetMask]) // Assign IP to the root router
        
        // Start assigning IPs to devices connected to the root router, using the next available subnet
        assignIPsRecursively(device.children, baseSubnet: rootRouterSubnet)
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
