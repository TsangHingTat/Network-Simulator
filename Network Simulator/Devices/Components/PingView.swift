//
//  PingView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct PingView: View {
    @State var deviceMac: String
    @State var deviceIp: String = "0.0.0.0"
    @State var pingIp: String = "192.168.1.1"
    @State var result: String = ""
    @State var showingSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Ping IP 地址")
                .font(.headline)

            TextField("輸入 IP 地址", text: $pingIp)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                pingIPAddress(pingIp)
                showingSheet = true
            }) {
                HStack {
                    Spacer()
                    Text("Ping")
                        .fontWeight(.bold)
                        .padding(6)
                    Spacer()
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .sheet(isPresented: $showingSheet) {
                PingResultSheet(result: $result)
            }
        }
        .padding()
        .background(isDarkMode() ? Color.black : Color.white)
        .cornerRadius(20)
    }

    func pingIPAddress(_ ipAddress: String) {
        result = "正在 Ping \(ipAddress)..."
        Task {
            let (pingable, ms) = pingable(deviceIp: deviceIp, pingIp: pingIp)
            if pingable {
                for i in 0..<50 {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    let pingResult = Int.random(in: 0...999)
                    result += "\n64 bytes from \(ipAddress): icmp_seq=\(i) ttl=64 time=\(ms).\(pingResult) ms"
                }
            } else {
                for i in 0..<50 {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    result += "\nRequest timeout for icmp_seq  icmp_seq=\(i)"
                }
            }
        }
    }
    
    func pingable(deviceIp: String, pingIp: String) -> (Bool, Int) {
        return (true, 3)
    }

}


#Preview {
    PingView(deviceMac: "00:00:00:00:00", deviceIp: "192.168.1.1", pingIp: "192.168.1.2")
        .padding()
}
