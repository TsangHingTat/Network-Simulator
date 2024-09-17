//
//  SymbolView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

struct SymbolView: View {
    @Binding var device: DeviceData
    @Binding var mainPastData: DeviceData
    @Binding var showMap: Bool
    @Binding var ipaddress: [[String]]
    
    var isChild = false
    var onDelete: (() -> Void)? 
    
    @State var isShowingInfo = false
    @State var isShowingAddSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isChild {
                    Image(systemName: "arrow.turn.down.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                HStack {
                    Image(systemName: device.symbol)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.title3)
                        Text(device.mac == "none" ? "Internet" : getIpAddressFromList(device.mac))
                            .font(.footnote)
                    }
                    Spacer()
                }
                .onTapGesture {
                    isShowingInfo.toggle()
                }
                .frame(width: 250)
                .padding(9)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .contextMenu {
                    Button(role: .destructive) {
                        onDelete?()
                        updateUI()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .sheet(isPresented: $isShowingInfo) {
                    ScrollView {
                        DeviceCardView(device: $device, connectDevices: usedPortCount())
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    .presentationDetents([.height(470), .fraction(1.0)])
                }
                .sheet(isPresented: $isShowingAddSheet) {
                    AddDeviceSheet(isShowingAddSheet: $isShowingAddSheet, device: $device, mainPastData: $mainPastData)
                        .onDisappear() {
                            updateUI()
                        }
                }
                if isSupportChild() {
                    Text(Image(systemName: "plus.circle.fill"))
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                        .onTapGesture {
                            isShowingAddSheet.toggle()
                        }
                }
            }
        }
    }
    
    func getIpAddressFromList(_ mac: String) -> String {
        for i in ipaddress {
            if i[0] == mac {
                return i[1]
            }
        }
        return "169.254.\(Int.random(in: 0...255)).\(Int.random(in: 0...255))"
    }
    
    func isSupportChild() -> Bool {
        let countNow = device.children.count
        let supportCount = device.lanQuantity
        return countNow < supportCount
    }
    
    func usedPortCount() -> Int {
        return device.children.count
    }
    
    func updateUI() -> Void {
        showMap.toggle()
    }
}


struct SymbolView_Previews: PreviewProvider {
    @State static var mockDevice = DeviceData(
        symbol: "wifi.router",
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
            )
        ]
    )
    
    @State static var mockMainPastData = mockDevice
    @State static var showMap = true

    static var previews: some View {
        SymbolView(
            device: $mockDevice,
            mainPastData: $mockMainPastData,
            showMap: $showMap,
            ipaddress: .constant([]),
            isChild: false,
            onDelete: {
                print("Delete action triggered")
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
