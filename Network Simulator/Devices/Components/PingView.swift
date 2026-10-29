//
//  PingView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct PingView: View {
    var sourceDevice: DeviceData?
    var networkRoot: DeviceData?

    @State var deviceMac: String = ""
    @State var deviceIp: String = "192.168.1.2"
    @State var pingIp: String = "192.168.1.1"
    @State var result: String = ""
    @State var showingSheet: Bool = false

    @State private var isPinging: Bool = false
    @State private var pingTask: Task<Void, Never>? = nil
    @State private var packetCount: Int = 4
    @State private var selectedTargetDevice: DeviceData? = nil

    private var availableTargets: [DeviceData] {
        guard let root = networkRoot ?? sourceDevice?.parent else { return [] }
        return root.allDevices().filter { $0.id != sourceDevice?.id && !$0.effectiveIP.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Ping 網絡連通性診斷", systemImage: "waveform.path")
                    .font(.headline)
                Spacer()
                if isPinging {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            // Target Quick Picker if multiple devices exist
            if !availableTargets.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("快速選擇拓撲中的目標設備")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(availableTargets) { target in
                                Button {
                                    pingIp = target.effectiveIP
                                    selectedTargetDevice = target
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: target.symbol)
                                        Text(target.name)
                                        Text("(\(target.effectiveIP))")
                                            .font(.caption2)
                                            .opacity(0.8)
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        pingIp == target.effectiveIP ? Color.blue : Color(.tertiarySystemFill),
                                        in: Capsule()
                                    )
                                    .foregroundColor(pingIp == target.effectiveIP ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }

            // Custom IP input
            VStack(alignment: .leading, spacing: 6) {
                Text("目標 IP 地址")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    TextField("輸入 IP 地址 (如 192.168.1.1 或 8.8.8.8)", text: $pingIp)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .autocorrectionDisabled()

                    // Preset buttons
                    Button("閘道") {
                        if let gw = sourceDevice?.effectiveGateway, !gw.isEmpty {
                            pingIp = gw
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)

                    Button("8.8.8.8") {
                        pingIp = "8.8.8.8"
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                if !isPinging {
                    Button {
                        startPing()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("開始 Ping")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.white)
                    }
                } else {
                    Button {
                        stopPing()
                    } label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("停止")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red, in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.white)
                    }
                }

                if !result.isEmpty {
                    Button {
                        showingSheet = true
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .padding(10)
                            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    Button {
                        result = ""
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Real-time Console Display
            if !result.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("終端輸出")
                            .font(.caption2.bold())
                            .foregroundColor(.secondary)
                        Spacer()
                    }

                    ScrollViewReader { proxy in
                        ScrollView {
                            Text(result)
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .id("terminalEnd")
                        }
                        .frame(maxHeight: 160)
                        .background(Color.black.opacity(0.92))
                        .cornerRadius(10)
                        .onChange(of: result) { _, _ in
                            withAnimation {
                                proxy.scrollTo("terminalEnd", anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .sheet(isPresented: $showingSheet) {
            PingResultSheet(result: $result)
        }
        .onDisappear {
            stopPing()
        }
    }

    func startPing() {
        let target = pingIp.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidIP(target) else {
            result = "ping: 無法解析主機或無效 IP 地址: \(target)\n"
            return
        }

        let myIP = sourceDevice?.effectiveIP ?? deviceIp
        result = "PING \(target) (\(target)) from \(myIP): 56 data bytes\n"
        isPinging = true

        pingTask = Task { @MainActor in
            var received = 0
            var latencies: [Double] = []
            let totalPackets = packetCount

            for seq in 0..<totalPackets {
                guard !Task.isCancelled else { break }

                try? await Task.sleep(nanoseconds: 800_000_000)
                guard !Task.isCancelled else { break }

                if let dev = sourceDevice {
                    let sim = dev.simulatePing(to: target)
                    if sim.success {
                        received += 1
                        latencies.append(sim.latencyMs)
                        let timeStr = String(format: "%.3f", sim.latencyMs)
                        result += "64 bytes from \(target): icmp_seq=\(seq) ttl=64 time=\(timeStr) ms\n"
                    } else {
                        result += "Request timeout for icmp_seq \(seq) (\(sim.message))\n"
                    }
                } else {
                    // Fallback
                    let ms = Double.random(in: 1.0...5.0)
                    received += 1
                    latencies.append(ms)
                    result += "64 bytes from \(target): icmp_seq=\(seq) ttl=64 time=\(String(format: "%.3f", ms)) ms\n"
                }
            }

            // Summary statistics
            if !Task.isCancelled {
                let lost = totalPackets - received
                let lossPct = (Double(lost) / Double(totalPackets)) * 100.0
                result += "\n--- \(target) ping 統計資料 ---\n"
                result += "\(totalPackets) packets transmitted, \(received) packets received, \(Int(lossPct))% packet loss\n"

                if !latencies.isEmpty {
                    let minRtt = latencies.min() ?? 0
                    let maxRtt = latencies.max() ?? 0
                    let avgRtt = latencies.reduce(0, +) / Double(latencies.count)
                    result += String(format: "round-trip min/avg/max = %.3f/%.3f/%.3f ms\n", minRtt, avgRtt, maxRtt)
                }
            }

            isPinging = false
        }
    }

    func stopPing() {
        pingTask?.cancel()
        pingTask = nil
        isPinging = false
    }
}

#Preview {
    PingView(
        deviceMac: "00:11:22:33:44:55",
        deviceIp: "192.168.1.10",
        pingIp: "192.168.1.1"
    )
    .padding()
}
