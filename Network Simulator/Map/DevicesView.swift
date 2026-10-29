//
//  DevicesView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct DeviceView: View {
    @Binding var device: DeviceData
    @Binding var mainPastData: DeviceData
    @Binding var showMap: Bool
    @Binding var ipaddress: [[String]]

    var isChild: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DeviceViewRecursive(
                device: $device,
                mainPastData: $mainPastData,
                showMap: $showMap,
                ipaddress: $ipaddress,
                indentLevel: 0,
                isChild: isChild
            )
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    @Previewable @State var sample = DeviceData(
        symbol: "network",
        type: "ISP",
        name: "數據機",
        mac: "none",
        wanQuantity: 0,
        lanQuantity: 4,
        pingSupport: true
    )
    @Previewable @State var showMap = true
    @Previewable @State var ips: [[String]] = []

    DeviceView(
        device: $sample,
        mainPastData: $sample,
        showMap: $showMap,
        ipaddress: $ips
    )
    .padding()
}
