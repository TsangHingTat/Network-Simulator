//
//  DHCPView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/13/24.
//

import SwiftUI

struct DHCPView: View {
    @Binding var network_v4: NetworkV4
    
    var body: some View {
        Text("DHCP 設定")
            .font(.headline)
        
        Picker("啟用 DHCP", selection: $network_v4.dhcpEnabled) {
            Text("啟用").tag(true)
            Text("停用").tag(false)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.bottom)
        
        if !network_v4.dhcpEnabled {
            Text("LAN 設定")
                .font(.headline)
                .padding(.top)
            
            TextField("IP 地址", text: $network_v4.ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numbersAndPunctuation)
                .onChange(of: network_v4.ipAddress) {
                    network_v4.showIPError = !isValidIP(network_v4.ipAddress)
                }
                .padding(.bottom)
            
            if network_v4.showIPError {
                Text("無效的 IP 地址")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.bottom, 5)
            }
            
            TextField("子網路遮罩", text: $network_v4.subnetMask)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numbersAndPunctuation)
                .onChange(of: network_v4.subnetMask) {
                    network_v4.showSubnetMaskError = !isValidSubnetMask(network_v4.subnetMask)
                }
                .padding(.bottom)
            
            if network_v4.showSubnetMaskError {
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
                network_v4: .constant(NetworkV4(
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
