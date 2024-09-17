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
    
    let deviceInfos: [DeviceInfo] = loadSymbolInfos()

    var body: some View {
        NavigationView {
            List {
                ForEach(deviceInfos, id: \.type) { info in
                    Button(action: {
                        var allMAC: [String] = []
                        
                        func getMAC(_ data: DeviceData) -> Void {
                            if data.mac != "none" {
                                allMAC.append(data.mac)
                            }
                            if data.children.count != 0 {
                                for i in data.children {
                                    getMAC(i)
                                }
                            }
                        }
                        
                        let existingMACs = allMAC
                        
                        let newMAC = generateMACAddress(existingMACs: existingMACs)
                        let newDeviceData = DeviceData(
                            symbol: info.icon,
                            type: info.type,
                            name: info.name,
                            mac: newMAC,
                            wanQuantity: info.wanQuantity,
                            lanQuantity: info.lanQuantity,
                            pingSupport: info.pingSupport
                        )
                        device.children.append(newDeviceData)
                        mainPastData.printDescription()
                        isShowingAddSheet = false
                    }) {
                        Label(info.name, systemImage: info.icon)
                    }
                }
            }
            .navigationTitle("添加設備")

        }
    }
}
