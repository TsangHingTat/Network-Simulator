//
//  SymbolView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

struct SymbolView: View {
    @Binding var device: DeviceData
    @Binding var mainPastData: DeviceData
    @Binding var showMap: Bool
    @Binding var ipaddress: [[String]]

    var isChild: Bool = false
    var onDelete: (() -> Void)? = nil

    @State private var isShowingInfo: Bool = false
    @State private var isShowingAddSheet: Bool = false
    @State private var isShowingPingSheet: Bool = false

    private var effectiveConnType: ConnectionType {
        if !device.isPoweredOn { return .offline }
        return device.connectionType
    }

    var body: some View {
        HStack(spacing: 8) {
            // Visual Cable Node Card
            HStack(spacing: 12) {
                // Device Icon with Connection Indicator
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: device.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(device.isPoweredOn ? .blue : .gray)

                    Circle()
                        .fill(effectiveConnType.color)
                        .frame(width: 8, height: 8)
                        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 1.5))
                        .offset(x: 2, y: 2)
                }
                .frame(width: 32, height: 32)

                // Device Name & IP Info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(device.name)
                            .font(.system(.subheadline, weight: .semibold))
                            .lineLimit(1)
                            .foregroundColor(device.isPoweredOn ? .primary : .secondary)

                        if !device.isPoweredOn {
                            Text("關機")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.red.opacity(0.15), in: Capsule())
                                .foregroundColor(.red)
                        }
                    }

                    HStack(spacing: 6) {
                        Text(displayIP)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)

                        if device.lanQuantity > 0 {
                            Text("• \(device.children.count)/\(device.lanQuantity) 埠")
                                .font(.system(size: 10))
                                .foregroundColor(device.canAddChild() ? .secondary : .orange)
                        }
                    }
                }

                Spacer()

                // Quick Action: Power toggle button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        device.isPoweredOn.toggle()
                        mainPastData.recalculateNetwork()
                        syncIPAddressList()
                    }
                } label: {
                    Image(systemName: "power")
                        .font(.caption)
                        .foregroundColor(device.isPoweredOn ? .green : .gray)
                        .padding(6)
                        .background(Color(.tertiarySystemFill), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(width: 280)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(effectiveConnType.color.opacity(device.isPoweredOn ? 0.3 : 0.1), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
            .onTapGesture {
                isShowingInfo.toggle()
            }
            .contextMenu {
                Button {
                    isShowingInfo = true
                } label: {
                    Label("設備詳情與設置", systemImage: "slider.horizontal.3")
                }

                Button {
                    withAnimation {
                        device.isPoweredOn.toggle()
                        mainPastData.recalculateNetwork()
                        syncIPAddressList()
                    }
                } label: {
                    Label(device.isPoweredOn ? "關閉設備電源" : "啟動設備電源", systemImage: "power")
                }

                if device.lanQuantity > 0 && device.canAddChild() {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Label("新增下級設備", systemImage: "plus.circle")
                    }
                }

                Divider()

                if onDelete != nil {
                    Button(role: .destructive) {
                        onDelete?()
                        mainPastData.recalculateNetwork()
                        syncIPAddressList()
                    } label: {
                        Label("刪除此設備", systemImage: "trash")
                    }
                }
            }
            .sheet(isPresented: $isShowingInfo) {
                NavigationStack {
                    ScrollView {
                        DeviceCardView(
                            device: $device,
                            connectionType: effectiveConnType,
                            connectDevices: device.children.count,
                            onUpdateTopology: {
                                mainPastData.recalculateNetwork()
                                syncIPAddressList()
                            }
                        )
                        .padding()
                    }
                    .navigationTitle(device.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完成") {
                                isShowingInfo = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddDeviceSheet(
                    isShowingAddSheet: $isShowingAddSheet,
                    device: $device,
                    mainPastData: $mainPastData,
                    showMap: $showMap
                )
            }

            // Add Child Device (+) Button
            if device.lanQuantity > 0 {
                Button {
                    if device.canAddChild() {
                        isShowingAddSheet.toggle()
                    }
                } label: {
                    Image(systemName: device.canAddChild() ? "plus.circle.fill" : "slash.circle")
                        .font(.system(size: 20))
                        .foregroundColor(device.canAddChild() ? .blue : .gray.opacity(0.4))
                }
                .disabled(!device.canAddChild())
                .help(device.canAddChild() ? "新增下級設備" : "端口已滿")
            }
        }
    }

    private var displayIP: String {
        if device.mac == "none" {
            return device.assignedIP.isEmpty ? "203.0.113.1" : device.assignedIP
        }
        let ip = device.effectiveIP
        return ip.isEmpty ? "未配置 IP" : ip
    }

    private func syncIPAddressList() {
        let all = mainPastData.allDevices()
        ipaddress = all.compactMap { d in
            d.effectiveIP.isEmpty ? nil : [d.mac, d.effectiveIP, d.effectiveSubnetMask]
        }
    }
}

#Preview {
    @Previewable @State var sample = DeviceData(
        symbol: "wifi.router",
        type: "router",
        name: "核心路由器",
        mac: "00:11:22:33:44:55",
        wanQuantity: 1,
        lanQuantity: 4,
        pingSupport: true,
        assignedIP: "192.168.1.1",
        connectionType: .internetConnection
    )
    @Previewable @State var showMap = true
    @Previewable @State var ips: [[String]] = []

    SymbolView(
        device: $sample,
        mainPastData: $sample,
        showMap: $showMap,
        ipaddress: $ips
    )
    .padding()
}
