//
//  DevicesView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct DeviceView: View {
    @Binding var selectedDeviceData: DeviceData?
    let device: DeviceData
    var onDelete: (DeviceData) -> Void // Callback function for delete action
    
    @State private var devicePosition: CGPoint = .zero
    @State private var deviceSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SymbolView(symbol: device.symbol, name: device.name, mac: device.mac)
                .contextMenu {
                    Button(action: {
                        onDelete(device) // Call the delete function
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .onTapGesture {
                    selectedDeviceData = device
                }
                .padding(.horizontal)
            
            if !device.children.isEmpty {
                ForEach(device.children) { child in
                    DeviceView(
                        selectedDeviceData: $selectedDeviceData,
                        device: child,
                        onDelete: onDelete
                    )
                    .padding(.leading, 50) // Indent children
                }
            }
        }
    }
}
