//
//  MapView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct MapView: View {
    @State var deviceData: DeviceData
    @State var showMap = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView {
                    if showMap {
                        DeviceView(
                            device: $deviceData,
                            mainPastData: $deviceData,
                            showMap: $showMap
                        )
                    } else {
                        Text("Loading...")
                            .onAppear() {
                                showMap.toggle()
                            }
                    }
                }
            }
            .navigationTitle("網路建構器")

        }
        .navigationViewStyle(.stack)
    }


}



struct MapView_Previews: PreviewProvider {
    @State static var mockDeviceData = DeviceData(
        symbol: "router",
        type: "Router",
        name: "Router",
        mac: "00:00:00:00:00:00",
        wanQuantity: 1,
        lanQuantity: 4,
        pingSupport: true,
        children: [
            DeviceData(
                symbol: "pc",
                type: "PC",
                name: "PC",
                mac: "00:00:00:00:00:01",
                wanQuantity: 0,
                lanQuantity: 0,
                pingSupport: true
            ),
            DeviceData(
                symbol: "switch",
                type: "Switch",
                name: "Switch",
                mac: "00:00:00:00:00:02",
                wanQuantity: 0,
                lanQuantity: 8,
                pingSupport: false
            )
        ]
    )
    
    @State static var showMap = true

    static var previews: some View {
        MapView(deviceData: mockDeviceData, showMap: showMap)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
