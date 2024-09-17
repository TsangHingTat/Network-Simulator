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
    
    var isChild = false
    
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
                    Color.clear
                        .frame(width: 45, height: 45)
                        .overlay() {
                            Text(Image(systemName: device.symbol))
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                        }
                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.title3)
                        ZStack {
                            Text(device.mac == "none" ? "No MAC Address   " : device.mac)
                                .font(.footnote)
                            Text(device.mac == "none" ? "00:00:00:00:00:00" : device.mac)
                                .font(.footnote)
                                .hidden()
                        }
                    }
                }
                .onTapGesture {
                    isShowingInfo.toggle()
                }
                .frame(minWidth: 190)
                .padding(9)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .sheet(isPresented: $isShowingInfo) {
                    ScrollView {
                        DeviceCardView(device: $device, connectDevices: usedPortCount())
                            .padding(.horizontal)
                    }
                        .presentationDetents([.height(470), .fraction(1.0)])
                }
                .sheet(isPresented: $isShowingAddSheet) {
                    AddDeviceSheet(isShowingAddSheet: $isShowingAddSheet, device: $device, mainPastData: $mainPastData)
                        .onDisappear() {
                            showMap.toggle()
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
    func isSupportChild() -> Bool {
        let countNow = device.children.count
        let supportCount = device.lanQuantity
        if countNow >= supportCount {
            return false
        } else {
            return true
        }
        
    }
    
    func usedPortCount() -> Int {
        return device.children.count
    }
}

