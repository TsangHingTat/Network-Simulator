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
            SymbolView(device: $device, mainPastData: $mainPastData, showMap: $showMap, isChild: isChild)
                .padding(.horizontal)
            
            if !device.children.isEmpty {
                ForEach($device.children) { child in
                    HStack {
                        Spacer()
                            .frame(width: 50)
                        DeviceView(
                            device: child, mainPastData: $mainPastData, showMap: $showMap,
                            isChild: true
                        )
                    }
                    
                }
            }
        }
    }

}
