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
        let subnetMask = "255.255.255.0" // 常用的子網掩碼，適用於 /24 網段
        var subnetIndex = subnetLevel // 記錄當前的子網索引

        // 幫助函數生成設備的下一個可用 IP
        func getNextAvailableIP(baseSubnet: String, hostIndex: Int) -> String {
            return "\(baseSubnet).\(hostIndex)" // 在當前子網中生成有效的 IP 地址
        }

        // 遞歸函數，用於分配 IP 地址，確保交換機使用父路由器的子網
        func assignIPsRecursively(_ devices: [DeviceData], baseSubnet: String) {
            var currentHostIP = 2 // 設備的 IP 從 .2 開始分配（預留 .1 給路由器）

            for device in devices {
                if device.type == "router" {
                    // 路由器會創建新的子網
                    let routerSubnet = "192.168.\(subnetIndex)"
                    let routerIP = "\(routerSubnet).1" // 路由器獲得自己子網中的 .1 IP 地址
                    ipaddress.append([device.mac, routerIP, subnetMask])
                    subnetIndex += 1 // 對於下一個路由器，遞增子網索引

                    // 遞歸分配 IP 給連接到該路由器的設備（使用新的子網）
                    assignIPsRecursively(device.children, baseSubnet: routerSubnet)
                } else if device.type == "switch" {
                    // 交換機不創建新的子網，使用父路由器的子網
                    let switchIP = getNextAvailableIP(baseSubnet: baseSubnet, hostIndex: currentHostIP)
                    ipaddress.append([device.mac, switchIP, subnetMask])
                    currentHostIP += 1 // 移動到下一個可用 IP

                    // 給連接到交換機的設備分配 IP（繼續使用父路由器的子網）
                    assignIPsRecursively(device.children, baseSubnet: baseSubnet)
                } else {
                    // 常規設備（例如 PC）在父路由器的子網中獲得 IP
                    let deviceIP = getNextAvailableIP(baseSubnet: baseSubnet, hostIndex: currentHostIP)
                    ipaddress.append([device.mac, deviceIP, subnetMask])
                    currentHostIP += 1
                }
            }
        }

        // 根路由器使用主子網（192.168.0.x）並開始遞歸分配 IP
        let rootRouterSubnet = "192.168.\(subnetLevel)" // 設置根路由器的基礎子網
        let rootRouterIP = "\(rootRouterSubnet).1"
        ipaddress.append([device.mac, rootRouterIP, subnetMask]) // 分配根路由器的 IP

        // 開始給連接到根路由器的設備分配 IP 地址，使用下一個可用子網
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
