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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showMap.toggle()
                        }
                        
                    }) {
                        Label(info.name, systemImage: info.icon)
                    }
                }
            }
            .navigationTitle("新增設備")
            
        }
    }
}


struct AddDeviceSheet_Previews: PreviewProvider {
    @State static var isShowingAddSheet = true
    @State static var mockDevice = DeviceData(symbol: "router", type: "Router", name: "Router", mac: "00:00:00:00:00:00", wanQuantity: 1, lanQuantity: 4, pingSupport: true)
    @State static var mockMainPastData = DeviceData(symbol: "router", type: "Router", name: "Router", mac: "00:00:00:00:00:00", wanQuantity: 1, lanQuantity: 4, pingSupport: true)
    
    static var previews: some View {
        AddDeviceSheet(isShowingAddSheet: $isShowingAddSheet, device: $mockDevice, mainPastData: $mockMainPastData, showMap: .constant(false))
    }
}
