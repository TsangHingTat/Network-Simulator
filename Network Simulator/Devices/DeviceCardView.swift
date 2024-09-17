//
//  DeviceCardView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/11/24.
//

import SwiftUI

struct DeviceCardView: View {
    @Binding var device: DeviceData

    @State var connectDevices: Int

    var body: some View {
        Spacer()
            .frame(height: 10)

        DeviceCardStatusView(
            deviceName: $device.name,
            symbol: $device.symbol,
            deviceStatus: .constant(false)
        )

        DeviceCardCellView(
            title: "連接狀態",
            string: getInternetStatus(device.mac).description,
            color: getColorFromInternetType(input: getInternetStatus(device.mac))
        )
        .shadow(radius: 1)

        RouterPortsView(ports: createPorts())
            .shadow(radius: 1)

        if device.pingSupport {
            PingView(deviceMac: device.mac)
                .shadow(radius: 1)
        }

        DeviceCardCellView(title: "設備 MAC 地址", string: device.mac)
            .shadow(radius: 1)
    }

    func getInternetStatus(_ mac: String) -> ConnectionType {
        return .internetConnection
    }

    func createPorts() -> [Port] {
        var ports: [Port] = []

        for i in 0..<device.wanQuantity {
            ports.append(Port(name: "Wan \(i)", isActive: i == 0))
        }
        
        for i in 0..<device.lanQuantity {
            ports.append(Port(name: "Lan \(i)", isActive: !((i + 1) > connectDevices)))
        }

        return ports
    }
}

#Preview {
    DeviceCardView(
        device: .constant(
            DeviceData(
                symbol: "wifi.router",
                type: "router",
                name: "Wi-Fi 路由器",
                mac: "00:00:00:00:00",
                wanQuantity: 1,
                lanQuantity: 4,
                pingSupport: true
            )
        ), connectDevices: 0
    )
}
