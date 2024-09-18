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
        
        // Get list of all routers
        let routers = findRouters(in: deviceData)
        
        // Assign IP addresses to all devices connected to each router
        for (index, router) in routers.enumerated() {
            // Use index to assign subnet (192.168.index.x for each router)
            let subnet = "192.168.\(index)"
            let devices = findDevicesForRouter(router: router)
            
            // Assign IPs to devices
            let assignedIPs = assignIPsToDevices(devices, subnet: subnet)
            updateIPAddress(with: assignedIPs)
        }
    }
    
    /// Find all routers in the network
    private func findRouters(in data: DeviceData) -> [DeviceData] {
        return data.children.filter { $0.type == "router" }
    }
    
    /// Find all devices that belong to the same subnet (children of the router)
    private func findDevicesForRouter(router: DeviceData) -> [DeviceData] {
        return router.children // Assuming direct children are connected to the router
    }
    
    /// Assign IP addresses to devices using the router's subnet range (DHCP-like logic)
    private func assignIPsToDevices(_ devices: [DeviceData], subnet: String) -> [[String]] {
        var tempIPList: [[String]] = []
        var currentHostIP = 2 // Start IP allocation at .2 (router is .1)
        let subnetMask = "255.255.255.0" // Common subnet mask for /24 networks
        
        func getNextAvailableIP() -> String {
            let ip = "\(subnet).\(currentHostIP)"
            currentHostIP += 1
            return ip
        }

        // Helper function to assign IPs recursively
        func assignIPsRecursively(_ devices: [DeviceData]) {
            for device in devices {
                if device.type == "switch" {
                    // Assign IP to the switch itself
                    let switchIP = getNextAvailableIP()
                    tempIPList.append([device.mac, switchIP, subnetMask])
                    
                    // Recursively assign IPs to devices connected to this switch
                    assignIPsRecursively(device.children)
                } else {
                    // Assign IP to the non-switch device
                    var ip: String
                    repeat {
                        ip = getNextAvailableIP()
                    } while ipaddress.contains(where: { $0[1] == ip }) // Ensure unique IP in subnet
                    
                    // Assign new IP to the device
                    tempIPList.append([device.mac, ip, subnetMask])
                }
            }
        }

        // Assign IPs starting from router
        let routerIP = "\(subnet).1"
        tempIPList.append([deviceData.mac, routerIP, subnetMask]) // Assign IP to the router

        // Assign IPs to all devices connected to the router
        assignIPsRecursively(devices)

        return tempIPList
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
                symbol: "pc",
                type: "pc",
                name: "PC",
                mac: "00:00:00:00:00:01",
                wanQuantity: 0,
                lanQuantity: 0,
                pingSupport: true
            ),
            DeviceData(
                symbol: "switch",
                type: "switch",
                name: "Switch",
                mac: "00:00:00:00:00:02",
                wanQuantity: 0,
                lanQuantity: 4,
                pingSupport: false,
                children: [
                    DeviceData(
                        symbol: "pc",
                        type: "pc",
                        name: "PC 2",
                        mac: "00:00:00:00:00:03",
                        wanQuantity: 0,
                        lanQuantity: 0,
                        pingSupport: true
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
