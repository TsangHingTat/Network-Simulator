//
//  MapView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct MapView: View {
    @State var deviceData: DeviceData
    @State var showMap: Bool = true
    @State var ipaddress: [[String]] = []

    @State private var zoomScale: CGFloat = 1.0
    @State private var showingOverviewList: Bool = false
    @State private var showingTemplateSheet: Bool = false

    private var allDevices: [DeviceData] {
        return deviceData.allDevices()
    }

    private var onlineCount: Int {
        return allDevices.filter { $0.isOnlineInNetwork() }.count
    }

    private var offlineCount: Int {
        return allDevices.count - onlineCount
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Network Stats Banner
                networkStatsBanner

                // Main Topology Canvas
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    VStack(alignment: .leading) {
                        DeviceView(
                            device: $deviceData,
                            mainPastData: $deviceData,
                            showMap: $showMap,
                            ipaddress: $ipaddress
                        )
                        .scaleEffect(zoomScale, anchor: .topLeading)
                        .padding(24)
                    }
                    .frame(minWidth: 600, minHeight: 600, alignment: .topLeading)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("網絡拓撲建構器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    // Zoom Controls
                    HStack(spacing: 4) {
                        Button {
                            withAnimation(.spring(response: 0.25)) {
                                zoomScale = max(0.6, zoomScale - 0.15)
                            }
                        } label: {
                            Image(systemName: "minus.magnifyingglass")
                        }

                        Text("\(Int(zoomScale * 100))%")
                            .font(.system(size: 11, design: .monospaced))
                            .frame(width: 42)

                        Button {
                            withAnimation(.spring(response: 0.25)) {
                                zoomScale = min(1.8, zoomScale + 0.15)
                            }
                        } label: {
                            Image(systemName: "plus.magnifyingglass")
                        }
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Refresh DHCP / Topology
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            deviceData.recalculateNetwork()
                            syncIPs()
                        }
                    } label: {
                        Label("重新計算 DHCP", systemImage: "arrow.clockwise")
                    }

                    // Network Device Inventory Sheet
                    Button {
                        showingOverviewList = true
                    } label: {
                        Label("設備清單", systemImage: "list.bullet.rectangle")
                    }

                    // Preset Templates Menu
                    Menu {
                        Button {
                            applyTemplate(.home)
                        } label: {
                            Label("預設家庭網絡", systemImage: "house")
                        }

                        Button {
                            applyTemplate(.office)
                        } label: {
                            Label("小型辦公室網絡", systemImage: "building.2")
                        }

                        Button {
                            applyTemplate(.cascaded)
                        } label: {
                            Label("多路由器層疊網絡", systemImage: "network")
                        }

                        Divider()

                        Button(role: .destructive) {
                            applyTemplate(.blank)
                        } label: {
                            Label("重設為空白數據機", systemImage: "trash")
                        }
                    } label: {
                        Label("網絡範本", systemImage: "square.grid.2x2")
                    }
                }
            }
            .onAppear {
                deviceData.recalculateNetwork()
                syncIPs()
            }
            .sheet(isPresented: $showingOverviewList) {
                NavigationStack {
                    List(allDevices) { dev in
                        HStack(spacing: 12) {
                            Image(systemName: dev.symbol)
                                .font(.title3)
                                .foregroundColor(dev.isOnlineInNetwork() ? .blue : .gray)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(dev.name)
                                        .font(.headline)
                                    if !dev.isPoweredOn {
                                        Text("關機")
                                            .font(.caption2.bold())
                                            .foregroundColor(.red)
                                    }
                                }

                                Text("IP: \(dev.effectiveIP.isEmpty ? "無" : dev.effectiveIP) • MAC: \(dev.mac)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Circle()
                                .fill(dev.isOnlineInNetwork() ? dev.connectionType.color : Color.gray)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .navigationTitle("全網絡設備總覽 (\(allDevices.count))")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完成") {
                                showingOverviewList = false
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Stats Banner
    private var networkStatsBanner: some View {
        HStack(spacing: 16) {
            statBadge(title: "總設備", value: "\(allDevices.count)", icon: "laptopcomputer.and.ipad", color: .blue)
            statBadge(title: "在線", value: "\(onlineCount)", icon: "checkmark.circle.fill", color: .green)
            statBadge(title: "離線", value: "\(offlineCount)", icon: "xmark.circle.fill", color: offlineCount > 0 ? .red : .secondary)

            let routerCount = allDevices.filter { $0.type.lowercased() == "router" }.count
            statBadge(title: "子網絡", value: "\(max(1, routerCount))", icon: "point.3.connected.trianglepath.dotted", color: .purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }

    private func statBadge(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(.subheadline, weight: .bold))
                Text(title)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func syncIPs() {
        ipaddress = allDevices.compactMap { d in
            d.effectiveIP.isEmpty ? nil : [d.mac, d.effectiveIP, d.effectiveSubnetMask]
        }
    }

    // MARK: - Template Presets
    enum NetworkTemplate {
        case home, office, cascaded, blank
    }

    private func applyTemplate(_ template: NetworkTemplate) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            switch template {
            case .home:
                deviceData = DeviceTemplates.homeNetwork()
            case .office:
                deviceData = DeviceTemplates.officeNetwork()
            case .cascaded:
                deviceData = DeviceTemplates.cascadedNetwork()
            case .blank:
                deviceData = DeviceTemplates.blankModem()
            }
            deviceData.recalculateNetwork()
            syncIPs()
        }
    }
}

// MARK: - Templates Factory
struct DeviceTemplates {
    static func blankModem() -> DeviceData {
        return DeviceData(
            symbol: "network",
            type: "ISP",
            name: "光纖數據機 (ISP)",
            mac: "none",
            wanQuantity: 0,
            lanQuantity: 4,
            pingSupport: true
        )
    }

    static func homeNetwork() -> DeviceData {
        let modem = blankModem()
        let router = DeviceData(
            symbol: "wifi.router",
            type: "router",
            name: "Wi-Fi 主路由器",
            mac: generateMACAddress(),
            wanQuantity: 1,
            lanQuantity: 4,
            pingSupport: true,
            children: [
                DeviceData(
                    symbol: "desktopcomputer",
                    type: "computer",
                    name: "個人電腦",
                    mac: generateMACAddress(),
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "tv",
                    type: "tv",
                    name: "客廳智能電視",
                    mac: generateMACAddress(),
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: false
                ),
                DeviceData(
                    symbol: "fanblades",
                    type: "fan",
                    name: "智能風扇",
                    mac: generateMACAddress(),
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: false
                )
            ]
        )
        modem.addChild(router)
        return modem
    }

    static func officeNetwork() -> DeviceData {
        let modem = blankModem()
        let mainRouter = DeviceData(
            symbol: "wifi.router",
            type: "router",
            name: "企業網關路由器",
            mac: generateMACAddress(),
            wanQuantity: 1,
            lanQuantity: 4,
            pingSupport: true
        )
        let coreSwitch = DeviceData(
            symbol: "server.rack",
            type: "switch",
            name: "24埠 核心交換機",
            mac: generateMACAddress(),
            wanQuantity: 0,
            lanQuantity: 24,
            pingSupport: true,
            children: [
                DeviceData(
                    symbol: "server.rack",
                    type: "web",
                    name: "公司 Web 伺服器",
                    mac: generateMACAddress(),
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "server.rack",
                    type: "dns",
                    name: "內部 DNS 伺服器",
                    mac: generateMACAddress(),
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "desktopcomputer",
                    type: "computer",
                    name: "研發部 工作站 1",
                    mac: generateMACAddress(),
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: true
                ),
                DeviceData(
                    symbol: "desktopcomputer",
                    type: "computer",
                    name: "研發部 工作站 2",
                    mac: generateMACAddress(),
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: true
                )
            ]
        )
        mainRouter.addChild(coreSwitch)
        modem.addChild(mainRouter)
        return modem
    }

    static func cascadedNetwork() -> DeviceData {
        let modem = blankModem()
        let router1 = DeviceData(
            symbol: "wifi.router",
            type: "router",
            name: "1樓 路由器",
            mac: generateMACAddress(),
            wanQuantity: 1,
            lanQuantity: 4,
            pingSupport: true
        )
        let router2 = DeviceData(
            symbol: "wifi.router",
            type: "router",
            name: "2樓 子路由器",
            mac: generateMACAddress(),
            wanQuantity: 1,
            lanQuantity: 4,
            pingSupport: true,
            children: [
                DeviceData(
                    symbol: "desktopcomputer",
                    type: "computer",
                    name: "2樓 辦公電腦",
                    mac: generateMACAddress(),
                    wanQuantity: 1,
                    lanQuantity: 0,
                    pingSupport: true
                )
            ]
        )
        let pc1 = DeviceData(
            symbol: "desktopcomputer",
            type: "computer",
            name: "1樓 收銀電腦",
            mac: generateMACAddress(),
            wanQuantity: 1,
            lanQuantity: 0,
            pingSupport: true
        )
        router1.addChild(router2)
        router1.addChild(pc1)
        modem.addChild(router1)
        return modem
    }
}

#Preview {
    MapView(deviceData: DeviceTemplates.homeNetwork())
}
