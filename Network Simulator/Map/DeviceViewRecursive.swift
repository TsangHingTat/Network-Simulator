//
//  DeviceViewRecursive.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/18/24.
//

import SwiftUI

struct DeviceViewRecursive: View {
    @Binding var device: DeviceData
    @Binding var mainPastData: DeviceData
    @Binding var showMap: Bool
    @Binding var ipaddress: [[String]]
    
    var indentLevel: Int
    var isChild: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Spacer().frame(width: CGFloat(indentLevel * 50))
                SymbolView(device: $device, mainPastData: $mainPastData, showMap: $showMap, ipaddress: $ipaddress, isChild: isChild, onDelete: {
                    if let parent = findParent(of: device, in: mainPastData) {
                        parent.children.removeAll { $0.id == device.id }
                    }
                })
                    .padding(.horizontal)
            }
            
            ForEach(device.children.indices, id: \.self) { index in
                DeviceViewRecursive(device: $device.children[index], mainPastData: $mainPastData, showMap: $showMap, ipaddress: $ipaddress, indentLevel: indentLevel + 1, isChild: true)
            }
        }
    }
    
    func findParent(of device: DeviceData, in data: DeviceData) -> DeviceData? {
        var stack = [data]
        while !stack.isEmpty {
            let current = stack.removeLast()
            if current.children.contains(where: { $0.id == device.id }) {
                return current
            }
            stack.append(contentsOf: current.children)
        }
        return nil
    }
    
}


struct DeviceViewRecursive_Previews: PreviewProvider {
    @State static var mockDevice = DeviceData(symbol: "router", type: "Router", name: "Router", mac: "00:00:00:00:00:00", wanQuantity: 1, lanQuantity: 4, pingSupport: true, children: [
        DeviceData(symbol: "pc", type: "PC", name: "PC", mac: "00:00:00:00:00:01", wanQuantity: 0, lanQuantity: 0, pingSupport: true),
        DeviceData(symbol: "switch", type: "Switch", name: "Switch", mac: "00:00:00:00:00:02", wanQuantity: 0, lanQuantity: 8, pingSupport: false)
    ])
    
    @State static var mockMainPastData = DeviceData(symbol: "router", type: "Router", name: "Router", mac: "00:00:00:00:00:00", wanQuantity: 1, lanQuantity: 4, pingSupport: true)
    @State static var showMap = true

    static var previews: some View {
        DeviceViewRecursive(
            device: $mockDevice,
            mainPastData: $mockMainPastData,
            showMap: $showMap,
            ipaddress: .constant([]),
            indentLevel: 0,
            isChild: false
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
