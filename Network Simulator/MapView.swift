//
//  MapView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct MapView: View {
    @State private var deviceDatas: [DeviceData] = []
    @State private var isShowingAddSheet: Bool = false
    @State private var selectedDeviceData: DeviceData? = nil
    let deviceInfos: [DeviceInfo] = loadSymbolInfos()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(deviceDatas) { data in
                        SymbolView(symbol: data.symbol, name: data.name, mac: data.mac)
                            .contextMenu {
                                Button(action: {
                                    deleteDevice(data)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                selectedDeviceData = data
                            }
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("網路建構器")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddSheet.toggle() }) {
                        Label("添加", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddDeviceSheet(deviceInfos: deviceInfos) { type in
                    if let newDeviceInfo = deviceInfos.first(where: { $0.type == type }) {
                        let existingMACs = deviceDatas.map { $0.mac }
                        let newMAC = generateMACAddress(existingMACs: existingMACs)
                        let newDeviceData = DeviceData(
                            symbol: newDeviceInfo.icon,
                            type: newDeviceInfo.type,
                            name: newDeviceInfo.name,
                            mac: newMAC,
                            wanQuantity: newDeviceInfo.wanQuantity,
                            lanQuantity: newDeviceInfo.lanQuantity,
                            pingSupport: newDeviceInfo.pingSupport
                        )
                        deviceDatas.append(newDeviceData)
                    }
                    isShowingAddSheet = false
                }
            }
            .popover(item: $selectedDeviceData) { data in
                ScrollView {
                    DeviceCardView(device: Binding(
                        get: { data },
                        set: { newValue in
                            if let index = deviceDatas.firstIndex(where: { $0.id == data.id }) {
                                deviceDatas[index] = newValue
                            }
                        }
                    ))
                    .padding(.horizontal, 10)
                }
                .presentationDetents([.height(470), .fraction(1.0)])
            }
        }
        .navigationViewStyle(.stack)
    }

    private func deleteDevice(_ device: DeviceData) {
        if let index = deviceDatas.firstIndex(where: { $0.id == device.id }) {
            deviceDatas.remove(at: index)
        }
    }

}
#Preview {
    MapView()
}
