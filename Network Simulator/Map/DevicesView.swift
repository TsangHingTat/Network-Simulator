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

// Encapsulated recursive structure in a separate view
struct DeviceViewRecursive: View {
    @Binding var device: DeviceData
    @Binding var mainPastData: DeviceData
    @Binding var showMap: Bool
    
    var indentLevel: Int
    var isChild: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Spacer().frame(width: CGFloat(indentLevel * 50))
                SymbolView(device: $device, mainPastData: $mainPastData, showMap: $showMap, isChild: isChild)
                    .padding(.horizontal)
            }
            
            ForEach(device.children.indices, id: \.self) { index in
                DeviceViewRecursive(device: $device.children[index], mainPastData: $mainPastData, showMap: $showMap, indentLevel: indentLevel + 1, isChild: true)
            }
        }
    }
}
