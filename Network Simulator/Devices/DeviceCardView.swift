//
//  DeviceCardView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/11/24.
//

import SwiftUI

struct DeviceCardView: View {
    @Binding var device: DeviceData
    var connectionType: ConnectionType = .noConnection
    var connectDevices: Int = 0
    var onUpdateTopology: (() -> Void)? = nil

    @State private var selectedTab: Int = 0

    private var effectiveConnType: ConnectionType {
        if !device.isPoweredOn { return .offline }
        return device.connectionType
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header: Status, Name, Power switch
            DeviceCardStatusView(
                deviceName: $device.name,
                symbol: $device.symbol,
                deviceStatus: $device.isPoweredOn
            )
            .onChange(of: device.isPoweredOn) { _, _ in
                onUpdateTopology?()
            }

            // Tab Picker
            Picker("分類", selection: $selectedTab) {
                Text("概覽").tag(0)
                Text("端口").tag(1)
                Text("IPv4 設定").tag(2)
                Text("Ping 診斷").tag(3)
            }
            .pickerStyle(.segmented)

            // Tab Contents
            if selectedTab == 0 {
                overviewSection
            } else if selectedTab == 1 {
                portsSection
            } else if selectedTab == 2 {
                networkConfigSection
            } else {
                pingSection
            }
        }
    }

    // MARK: - Sections
    private var overviewSection: some View {
        VStack(spacing: 10) {
            DeviceCardCellView(
                icon: effectiveConnType.sfSymbol,
                title: "連接狀態",
                string: effectiveConnType.description,
                color: effectiveConnType.color
            )

            DeviceCardCellView(
                icon: "network",
                title: "IP 地址",
                string: device.effectiveIP.isEmpty ? "未分配" : device.effectiveIP,
                color: .primary,
                isCopyable: true
            )

            DeviceCardCellView(
                icon: "shield.checkered",
                title: "子網絡遮罩",
                string: device.effectiveSubnetMask,
                color: .secondary,
                isCopyable: true
            )

            if !device.effectiveGateway.isEmpty {
                DeviceCardCellView(
                    icon: "arrow.triangle.branch",
                    title: "預設閘道 (Gateway)",
                    string: device.effectiveGateway,
                    color: .secondary,
                    isCopyable: true
                )
            }

            DeviceCardCellView(
                icon: "barcode.viewfinder",
                title: "設備 MAC 地址",
                string: device.mac == "none" ? "ISP 外部接入" : device.mac,
                color: .primary,
                isCopyable: device.mac != "none"
            )

            DeviceCardCellView(
                icon: "point.3.connected.trianglepath.dotted",
                title: "下級連接設備數",
                string: "\(device.children.count) / \(device.lanQuantity) (最大可用)",
                color: device.canAddChild() ? .blue : .orange
            )
        }
    }

    private var portsSection: some View {
        VStack(spacing: 12) {
            RouterPortsView(portItems: generatePortItems())
        }
    }

    private var networkConfigSection: some View {
        DHCPView(network_v4: $device.networkV4) {
            onUpdateTopology?()
        }
    }

    private var pingSection: some View {
        PingView(
            sourceDevice: device,
            networkRoot: device.parent == nil ? device : findRoot(device),
            deviceMac: device.mac,
            deviceIp: device.effectiveIP
        )
    }

    private func findRoot(_ d: DeviceData) -> DeviceData {
        var current = d
        while let p = current.parent {
            current = p
        }
        return current
    }

    private func generatePortItems() -> [PortItem] {
        var list: [PortItem] = []

        // WAN Ports
        for i in 0..<device.wanQuantity {
            let isParentConnected = device.parent != nil
            list.append(PortItem(
                name: "WAN \(i)",
                isWan: true,
                isActive: isParentConnected,
                connectedDeviceName: device.parent?.name
            ))
        }

        // LAN Ports
        for i in 0..<device.lanQuantity {
            let hasChild = i < device.children.count
            let childName = hasChild ? device.children[i].name : nil
            list.append(PortItem(
                name: "LAN \(i + 1)",
                isWan: false,
                isActive: hasChild,
                connectedDeviceName: childName
            ))
        }

        return list
    }
}

#Preview {
    @Previewable @State var sampleDevice = DeviceData(
        symbol: "wifi.router",
        type: "router",
        name: "客廳路由器",
        mac: "02:11:22:33:44:55",
        wanQuantity: 1,
        lanQuantity: 4,
        pingSupport: true,
        assignedIP: "192.168.1.1",
        connectionType: .internetConnection
    )

    ScrollView {
        DeviceCardView(device: $sampleDevice, connectionType: .internetConnection, connectDevices: 2)
            .padding()
    }
}
