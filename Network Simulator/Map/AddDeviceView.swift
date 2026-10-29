//
//  AddDeviceView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

struct AddDeviceSheet: View {
    @Binding var isShowingAddSheet: Bool
    @Binding var device: DeviceData
    @Binding var mainPastData: DeviceData
    @Binding var showMap: Bool

    @State private var searchText: String = ""
    @State private var selectedCategory: DeviceCategory = .all

    private let deviceInfos: [DeviceInfo] = loadSymbolInfos()

    private var filteredDevices: [DeviceInfo] {
        deviceInfos.filter { info in
            let matchesCategory = (selectedCategory == .all || info.category == selectedCategory)
            let matchesSearch = searchText.isEmpty ||
                                info.name.localizedCaseInsensitiveContains(searchText) ||
                                info.type.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DeviceCategory.allCases) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    selectedCategory == category ? Color.blue : Color(.tertiarySystemFill),
                                    in: Capsule()
                                )
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                List {
                    Section {
                        HStack {
                            Label("連接目標設備", systemImage: device.symbol)
                                .font(.subheadline)
                            Spacer()
                            Text("\(device.name) (剩餘 \(device.lanQuantity - device.children.count) 埠)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section("可添加設備列表 (\(filteredDevices.count))") {
                        if filteredDevices.isEmpty {
                            ContentUnavailableView(
                                "未找到相符設備",
                                systemImage: "questionmark.circle",
                                description: Text("請嘗試搜尋其他關鍵字或切換類別")
                            )
                        } else {
                            ForEach(filteredDevices) { info in
                                Button {
                                    addNewDevice(from: info)
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: info.icon)
                                            .font(.title2)
                                            .frame(width: 32)
                                            .foregroundColor(.blue)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(info.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)

                                            HStack(spacing: 8) {
                                                if info.wanQuantity > 0 {
                                                    Text("WAN: \(info.wanQuantity)")
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                }
                                                if info.lanQuantity > 0 {
                                                    Text("LAN: \(info.lanQuantity)")
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                }
                                                if info.pingSupport {
                                                    Text("支援 Ping")
                                                        .font(.caption2)
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }

                                        Spacer()

                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜尋設備名稱或類型...")
            .navigationTitle("新增下級設備")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isShowingAddSheet = false
                    }
                }
            }
        }
    }

    private func addNewDevice(from info: DeviceInfo) {
        let existingMACs = mainPastData.allMACs()
        let newMAC = generateMACAddress(existingMACs: existingMACs)

        let newDeviceData = DeviceData(
            symbol: info.icon,
            type: info.type,
            name: info.name,
            mac: newMAC,
            wanQuantity: info.wanQuantity,
            lanQuantity: info.lanQuantity,
            pingSupport: info.pingSupport,
            children: [],
            parent: device,
            isPoweredOn: true
        )

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            device.addChild(newDeviceData)
            mainPastData.recalculateNetwork()
        }

        isShowingAddSheet = false
    }
}

#Preview {
    @Previewable @State var isShowing = true
    @Previewable @State var parent = DeviceData(
        symbol: "wifi.router",
        type: "router",
        name: "路由器",
        mac: "00:11:22:33:44:55",
        wanQuantity: 1,
        lanQuantity: 4,
        pingSupport: true
    )
    @Previewable @State var showMap = true

    AddDeviceSheet(
        isShowingAddSheet: $isShowing,
        device: $parent,
        mainPastData: $parent,
        showMap: $showMap
    )
}
