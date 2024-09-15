//
//  DHCPView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/13/24.
//

import SwiftUI

struct DHCPView: View {
    @Binding var network_v1: NetworkV1
    
    var body: some View {
        Text("DHCP 設定")
            .font(.headline)
        
        Picker("啟用 DHCP", selection: $network_v1.dhcpEnabled) {
            Text("啟用").tag(true)
            Text("停用").tag(false)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.bottom)
        
        if !network_v1.dhcpEnabled {
            Text("LAN 設定")
                .font(.headline)
                .padding(.top)
            
            TextField("IP 地址", text: $network_v1.ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numbersAndPunctuation)
                .onChange(of: network_v1.ipAddress) {
                    network_v1.showIPError = !isValidIP(network_v1.ipAddress)
                }
                .padding(.bottom)
            
            if network_v1.showIPError {
                Text("無效的 IP 地址")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.bottom, 5)
            }
            
            TextField("子網路遮罩", text: $network_v1.subnetMask)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numbersAndPunctuation)
                .onChange(of: network_v1.subnetMask) {
                    network_v1.showSubnetMaskError = !isValidSubnetMask(network_v1.subnetMask)
                }
                .padding(.bottom)
            
            if network_v1.showSubnetMaskError {
                Text("無效的子網路遮罩")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.bottom, 5)
            }
        }
    }
}

struct DHCPView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DHCPView(
                network_v1: .constant(NetworkV1(
                    dhcpEnabled: false,
                    ipAddress: "192.168.1.1",
                    subnetMask: "255.255.255.0",
                    showIPError: false,
                    showSubnetMaskError: false
                ))
            )
            .padding()
        }
    }
}
