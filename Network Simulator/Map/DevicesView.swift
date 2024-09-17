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
    
    var isChild = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            DeviceViewRecursive(device: $device, mainPastData: $mainPastData, showMap: $showMap, indentLevel: 0, isChild: isChild)
        }
    }
}


struct DeviceView_Previews: PreviewProvider {
    @State static var mockDevice = DeviceData(symbol: "router", type: "Router", name: "Router", mac: "00:00:00:00:00:00", wanQuantity: 1, lanQuantity: 4, pingSupport: true, children: [
        DeviceData(symbol: "pc", type: "PC", name: "PC", mac: "00:00:00:00:00:01", wanQuantity: 0, lanQuantity: 0, pingSupport: true)
    ])
    
    @State static var mockMainPastData = DeviceData(symbol: "router", type: "Router", name: "Router", mac: "00:00:00:00:00:00", wanQuantity: 1, lanQuantity: 4, pingSupport: true)
    @State static var showMap = true

    static var previews: some View {
        DeviceView(
            device: $mockDevice,
            mainPastData: $mockMainPastData,
            showMap: $showMap
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
