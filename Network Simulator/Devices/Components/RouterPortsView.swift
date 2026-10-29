//
//  RouterPortsView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct PortItem: Identifiable, Hashable {
    let id: String
    let name: String
    let isWan: Bool
    let isActive: Bool
    let connectedDeviceName: String?
    let speed: String

    init(name: String, isWan: Bool = false, isActive: Bool = false, connectedDeviceName: String? = nil, speed: String = "1 Gbps") {
        self.id = name
        self.name = name
        self.isWan = isWan
        self.isActive = isActive
        self.connectedDeviceName = connectedDeviceName
        self.speed = speed
    }
}

// Backward-compatible Port struct
struct Port: Hashable {
    let name: String
    let isActive: Bool
}

struct RouterPortsView: View {
    var ports: [Port] = []
    var portItems: [PortItem] = []

    private var displayPorts: [PortItem] {
        if !portItems.isEmpty {
            return portItems
        }
        return ports.map { p in
            let isWan = p.name.lowercased().contains("wan")
            return PortItem(name: p.name, isWan: isWan, isActive: p.isActive)
        }
    }

    private let gridItems = [GridItem(.adaptive(minimum: 85), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("連接埠狀態 (RJ45)", systemImage: "cable.connector")
                    .font(.headline)
                Spacer()
                Text("\(displayPorts.filter { $0.isActive }.count)/\(displayPorts.count) 啟用")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemFill), in: Capsule())
            }

            if displayPorts.isEmpty {
                Text("此設備無物理網絡接口")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(columns: gridItems, spacing: 14) {
                    ForEach(displayPorts) { port in
                        VStack(spacing: 6) {
                            RJ45PortView(
                                color: port.isWan ? .blue : (port.isActive ? .green : .secondary),
                                isConnected: port.isActive,
                                isLinkActive: port.isActive
                            )
                            .frame(width: 44, height: 44)

                            Text(port.name)
                                .font(.caption2.bold())
                                .foregroundColor(port.isWan ? .blue : .primary)

                            if let connectedName = port.connectedDeviceName {
                                Text(connectedName)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            } else {
                                Text(port.isActive ? "已連接" : "空閒")
                                    .font(.system(size: 9))
                                    .foregroundColor(port.isActive ? .green : .secondary)
                            }
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemGroupedBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(port.isActive ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    RouterPortsView(portItems: [
        PortItem(name: "WAN 0", isWan: true, isActive: true, connectedDeviceName: "光纖數據機"),
        PortItem(name: "LAN 1", isWan: false, isActive: true, connectedDeviceName: "辦公室 PC"),
        PortItem(name: "LAN 2", isWan: false, isActive: true, connectedDeviceName: "交換機 1"),
        PortItem(name: "LAN 3", isWan: false, isActive: false),
        PortItem(name: "LAN 4", isWan: false, isActive: false)
    ])
    .padding()
}
