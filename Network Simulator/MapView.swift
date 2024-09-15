//
//  MapView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct MapView: View {
    @State var deviceDatas: [DeviceData] = []
    @State var isShowingAddSheet: Bool = false
    @State var selectedDeviceData: DeviceData? = nil
    let deviceInfos: [DeviceInfo] = loadSymbolInfos()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(deviceDatas) { data in
                        DeviceView(
                            selectedDeviceData: $selectedDeviceData,
                            device: data,
                            onDelete: deleteDevice
                        )
                    }
                }
            }
            .navigationTitle("網路建構器")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddSheet.toggle() }) {
                        Label("添加", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddDeviceSheet(deviceInfos: deviceInfos) { type in
                    if let newDeviceInfo = deviceInfos.first(where: { $0.type == type }) {
                        let existingMACs = deviceDatas.map { $0.mac }
                        let newMAC = generateMACAddress(existingMACs: existingMACs)
                        let newDeviceData = DeviceData(
                            symbol: newDeviceInfo.icon,
                            type: newDeviceInfo.type,
                            name: newDeviceInfo.name,
                            mac: newMAC,
                            wanQuantity: newDeviceInfo.wanQuantity,
                            lanQuantity: newDeviceInfo.lanQuantity,
                            pingSupport: newDeviceInfo.pingSupport
                        )
                        deviceDatas.append(newDeviceData)
                    }
                    isShowingAddSheet = false
                }
            }
            .sheet(item: $selectedDeviceData) { data in
                ScrollView {
                    DeviceCardView(device: Binding(
                        get: { data },
                        set: { newValue in
                            if let index = deviceDatas.firstIndex(where: { $0.id == data.id }) {
                                deviceDatas[index] = newValue
                            }
                        }
                    ))
                    .padding(.horizontal, 10)
                }
//                .presentationDetents([.height(470), .fraction(1.0)])
            }
        }
        .navigationViewStyle(.stack)
    }

    private func deleteDevice(_ device: DeviceData) {
        if let index = deviceDatas.firstIndex(where: { $0.id == device.id }) {
            deviceDatas.remove(at: index)
        }
    }
}


#Preview {
    MapView(deviceDatas: [
        DeviceData(
            symbol: "network",
            type: "ISP",
            name: "互聯網服務供應商",
            mac: "none",
            wanQuantity: 1,
            lanQuantity: 0,
            pingSupport: true,
            children: [
                DeviceData(
                    symbol: "wifi.router",
                    type: "router",
                    name: "WiFi 路由器",
                    mac: "00:00:00:00:00:02",
                    wanQuantity: 1,
                    lanQuantity: 4,
                    pingSupport: true,
                    children: [
                        DeviceData(
                            symbol: "server.rack",
                            type: "switch",
                            name: "網絡交換機 1",
                            mac: "00:00:00:00:00:03",
                            wanQuantity: 0,
                            lanQuantity: 24,
                            pingSupport: true,
                            children: [
                                DeviceData(
                                    symbol: "desktopcomputer",
                                    type: "computer",
                                    name: "電腦 1",
                                    mac: "00:00:00:00:00:04",
                                    wanQuantity: 0,
                                    lanQuantity: 1,
                                    pingSupport: true
                                ),
                                DeviceData(
                                    symbol: "tv",
                                    type: "tv",
                                    name: "電視 1",
                                    mac: "00:00:00:00:00:05",
                                    wanQuantity: 0,
                                    lanQuantity: 1,
                                    pingSupport: false
                                )
                            ]
                        ),
                        DeviceData(
                            symbol: "server.rack",
                            type: "switch",
                            name: "網絡交換機 2",
                            mac: "00:00:00:00:00:06",
                            wanQuantity: 0,
                            lanQuantity: 24,
                            pingSupport: true,
                            children: [
                                DeviceData(
                                    symbol: "fanblades",
                                    type: "fan",
                                    name: "智能風扇 1",
                                    mac: "00:00:00:00:00:07",
                                    wanQuantity: 0,
                                    lanQuantity: 1,
                                    pingSupport: false
                                ),
                                DeviceData(
                                    symbol: "fanblades",
                                    type: "fan",
                                    name: "智能風扇 2",
                                    mac: "00:00:00:00:00:08",
                                    wanQuantity: 0,
                                    lanQuantity: 1,
                                    pingSupport: false,
                                    children: [
                                        DeviceData(
                                            symbol: "tv",
                                            type: "tv",
                                            name: "電視 2",
                                            mac: "00:00:00:00:00:09",
                                            wanQuantity: 0,
                                            lanQuantity: 1,
                                            pingSupport: false
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "web",
                    name: "網頁伺服器",
                    mac: "00:00:00:00:00:0A",
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "vpn",
                    name: "VPN 伺服器",
                    mac: "00:00:00:00:00:0B",
                    wanQuantity: 1,
                    lanQuantity: 1,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "dns",
                    name: "DNS 伺服器",
                    mac: "00:00:00:00:00:0C",
                    wanQuantity: 1,
                    lanQuantity: 1,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "firewall",
                    name: "防火牆",
                    mac: "00:00:00:00:00:0D",
                    wanQuantity: 1,
                    lanQuantity: 1,
                    pingSupport: false
                )
            ]
        )
    ])
}
