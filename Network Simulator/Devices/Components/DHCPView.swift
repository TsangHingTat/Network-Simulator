//
//  DHCPView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/13/24.
//

import SwiftUI

struct DHCPView: View {
    @Binding var network_v4: NetworkV4
    var onConfigurationChanged: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("IPv4 網絡配置", systemImage: "network.badge.shield.half.filled")
                    .font(.headline)
                Spacer()
                Text(network_v4.dhcpEnabled ? "DHCP 自動取得" : "手動靜態 IP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Picker("配置模式", selection: $network_v4.dhcpEnabled) {
                Text("DHCP (自動)").tag(true)
                Text("靜態 IP (手動)").tag(false)
            }
            .pickerStyle(.segmented)
            .onChange(of: network_v4.dhcpEnabled) { _, _ in
                onConfigurationChanged?()
            }

            if !network_v4.dhcpEnabled {
                VStack(spacing: 12) {
                    // IP Address
                    VStack(alignment: .leading, spacing: 4) {
                        Text("IP 地址 (IPv4)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("例如 192.168.1.100", text: $network_v4.ipAddress)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numbersAndPunctuation)
                            .autocorrectionDisabled()
                            .onChange(of: network_v4.ipAddress) { _, newValue in
                                network_v4.showIPError = !newValue.isEmpty && !isValidIP(newValue)
                                onConfigurationChanged?()
                            }

                        if network_v4.showIPError {
                            Text("無效的 IPv4 地址 (應為 4 個 0-255 的數字，如 192.168.1.5)")
                                .foregroundColor(.red)
                                .font(.caption2)
                        }
                    }

                    // Subnet Mask
                    VStack(alignment: .leading, spacing: 4) {
                        Text("子網絡遮罩")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("例如 255.255.255.0", text: $network_v4.subnetMask)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numbersAndPunctuation)
                            .autocorrectionDisabled()
                            .onChange(of: network_v4.subnetMask) { _, newValue in
                                network_v4.showSubnetMaskError = !newValue.isEmpty && !isValidSubnetMask(newValue)
                                onConfigurationChanged?()
                            }

                        if network_v4.showSubnetMaskError {
                            Text("無效的子網絡遮罩 (如 255.255.255.0)")
                                .foregroundColor(.red)
                                .font(.caption2)
                        }
                    }

                    // Default Gateway
                    VStack(alignment: .leading, spacing: 4) {
                        Text("預設閘道 (Gateway)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("例如 192.168.1.1", text: $network_v4.gateway)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numbersAndPunctuation)
                            .autocorrectionDisabled()
                            .onChange(of: network_v4.gateway) { _, newValue in
                                network_v4.showGatewayError = !newValue.isEmpty && !isValidIP(newValue)
                                onConfigurationChanged?()
                            }

                        if network_v4.showGatewayError {
                            Text("無效的閘道 IP 地址")
                                .foregroundColor(.red)
                                .font(.caption2)
                        }
                    }

                    // DNS Server
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DNS 伺服器")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("例如 8.8.8.8", text: $network_v4.dns)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numbersAndPunctuation)
                            .autocorrectionDisabled()
                            .onChange(of: network_v4.dns) { _, _ in
                                onConfigurationChanged?()
                            }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    @Previewable @State var net = NetworkV4(
        dhcpEnabled: false,
        ipAddress: "192.168.1.50",
        subnetMask: "255.255.255.0",
        gateway: "192.168.1.1",
        dns: "8.8.8.8"
    )

    DHCPView(network_v4: $net)
        .padding()
}
