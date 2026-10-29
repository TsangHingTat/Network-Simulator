//
//  DeviceCardStatusView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct DeviceCardStatusView: View {
    @Binding var deviceName: String
    @Binding var symbol: String
    @Binding var deviceStatus: Bool

    @State private var isEditing: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(deviceStatus ? Color.blue.opacity(0.15) : Color.gray.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(deviceStatus ? .blue : .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    HStack {
                        TextField("設備名稱", text: $deviceName)
                            .focused($isFocused)
                            .textFieldStyle(.roundedBorder)
                            .font(.headline)
                            .onSubmit {
                                isEditing = false
                            }

                        Button("完成") {
                            isEditing = false
                            isFocused = false
                        }
                        .font(.subheadline)
                    }
                } else {
                    HStack(spacing: 6) {
                        Text(deviceName)
                            .font(.title3.bold())
                            .foregroundColor(.primary)

                        Button {
                            isEditing = true
                            isFocused = true
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text(deviceStatus ? "運行中" : "已關機")
                        .font(.caption)
                        .foregroundColor(deviceStatus ? .green : .red)
                }
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    deviceStatus.toggle()
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "power.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(deviceStatus ? .green : .red.opacity(0.6))

                    Text(deviceStatus ? "開機" : "關機")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(deviceStatus ? .green : .secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    @Previewable @State var name = "辦公室核心路由器"
    @Previewable @State var symbol = "wifi.router"
    @Previewable @State var status = true

    DeviceCardStatusView(deviceName: $name, symbol: $symbol, deviceStatus: $status)
        .padding()
}
