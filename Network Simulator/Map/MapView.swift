//
//  MapView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct MapView: View {
    @State var deviceData: DeviceData
    @State var showMap = false
    @State var ipaddress: [[String]] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView {
                    if showMap {
                        DeviceView(
                            device: $deviceData,
                            mainPastData: $deviceData,
                            showMap: $showMap,
                            ipaddress: $ipaddress
                        )
                    } else {
                        Text("Loading...")
                            .onAppear() {
                                dhcp()
                                showMap.toggle()
                            }
                    }
                }
            }
            .navigationTitle("網路建構器")

        }
        .navigationViewStyle(.stack)
    }
    
    func dhcp() -> Void {
        print("DHCP Started")
        var temp0: [String] = []
        func findRouter(_ input: DeviceData) -> Void {
            for i in input.children {
                if i.type == "router" {
                    temp0.append(i.mac)
                }
            }
        }
        findRouter(deviceData)
        var foundedInt = 0
        var temp1: [[String]] = []
        func runDhcp() -> Void {
            for i in deviceData.children {
                for j in temp0 {
                    if i.mac == j {
                        temp1.append([i.mac, "192.168.\(foundedInt).1"])
                        foundedInt += 1
                    }
                }
            }
        }
        runDhcp()
        
        if temp1.count != 0 {
            for i in 0...temp1.count-1 {
                if ipaddress.count != 0 {
                    for j in 0...ipaddress.count-1 {
                        if temp1[i][0] == ipaddress[j][0] {
                            ipaddress.remove(at: j)
                        }
                    }
                }
            }
        }
        
        for i in temp1 {
            ipaddress.append(i)
            print("Add iP \(i)")
        }
        
    }

}



struct MapView_Previews: PreviewProvider {
    @State static var mockDeviceData = DeviceData(
        symbol: "wifi.router",
        type: "router",
        name: "Router",
        mac: "00:00:00:00:00:00",
        wanQuantity: 1,
        lanQuantity: 4,
        pingSupport: true,
        children: [
            DeviceData(
                symbol: "pc",
                type: "pc",
                name: "PC",
                mac: "00:00:00:00:00:01",
                wanQuantity: 0,
                lanQuantity: 0,
                pingSupport: true
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
