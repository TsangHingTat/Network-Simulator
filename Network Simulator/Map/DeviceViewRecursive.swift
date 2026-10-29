//
//  DeviceViewRecursive.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/18/24.
//

import SwiftUI

struct DeviceViewRecursive: View {
    @Binding var device: DeviceData
    @Binding var mainPastData: DeviceData
    @Binding var showMap: Bool
    @Binding var ipaddress: [[String]]

    var indentLevel: Int = 0
    var isChild: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                // Indentation space and tree branch guide
                if indentLevel > 0 {
                    HStack(spacing: 0) {
                        ForEach(0..<indentLevel, id: \.self) { level in
                            ZStack {
                                // Vertical trunk line
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.25))
                                    .frame(width: 2)
                                    .padding(.vertical, -5)

                                // Elbow line to current node
                                if level == indentLevel - 1 {
                                    VStack {
                                        Spacer()
                                        Rectangle()
                                            .fill(Color.secondary.opacity(0.25))
                                            .frame(height: 2)
                                        Spacer()
                                    }
                                }
                            }
                            .frame(width: 32)
                        }
                    }
                }

                // Node card
                SymbolView(
                    device: $device,
                    mainPastData: $mainPastData,
                    showMap: $showMap,
                    ipaddress: $ipaddress,
                    isChild: isChild,
                    onDelete: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            _ = mainPastData.removeChild(id: device.id)
                            mainPastData.recalculateNetwork()
                        }
                    }
                )
            }

            // Safe child enumeration using stable IDs
            ForEach($device.children) { $child in
                DeviceViewRecursive(
                    device: $child,
                    mainPastData: $mainPastData,
                    showMap: $showMap,
                    ipaddress: $ipaddress,
                    indentLevel: indentLevel + 1,
                    isChild: true
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var sample = DeviceData(
        symbol: "network",
        type: "ISP",
        name: "光纖數據機",
        mac: "none",
        wanQuantity: 0,
        lanQuantity: 4,
        pingSupport: true,
        children: [
            DeviceData(
                symbol: "wifi.router",
                type: "router",
                name: "主路由器",
                mac: "02:11:22:33:44:55",
                wanQuantity: 1,
                lanQuantity: 4,
                pingSupport: true,
                children: [
                    DeviceData(
                        symbol: "desktopcomputer",
                        type: "computer",
                        name: "Mac mini",
                        mac: "02:AA:BB:CC:DD:EE",
                        wanQuantity: 1,
                        lanQuantity: 0,
                        pingSupport: true
                    )
                ]
            )
        ]
    )
    @Previewable @State var showMap = true
    @Previewable @State var ipaddress: [[String]] = []

    ScrollView([.horizontal, .vertical]) {
        DeviceViewRecursive(
            device: $sample,
            mainPastData: $sample,
            showMap: $showMap,
            ipaddress: $ipaddress
        )
        .padding()
    }
}
