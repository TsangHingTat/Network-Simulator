//
//  RouterView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/11/24.
//

import SwiftUI

struct RouterView: View {
    @State private var deviceName: String = "Device Name"
    @State private var dhcpEnabled: Bool = true
    @State private var ipAddress: String = ""
    @State private var subnetMask: String = ""
    @State private var showIPError: Bool = false
    @State private var showSubnetMaskError: Bool = false
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                // Rename Device Section
                Text("Rename Device")
                    .font(.headline)
                
                TextField("Enter device name", text: $deviceName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
                
                // DHCP Settings Section
                Text("DHCP Settings")
                    .font(.headline)
                
                Picker("Enable DHCP", selection: $dhcpEnabled) {
                    Text("Enabled").tag(true)
                    Text("Disabled").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)
                
                // LAN Settings for Static IP and Subnet Mask
                if !dhcpEnabled {
                    Text("LAN Settings")
                        .font(.headline)
                        .padding(.top)
                    
                    // IP Address Input
                    TextField("IP Address", text: $ipAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                        .onChange(of: ipAddress) {
                            showIPError = !isValidIP(ipAddress)
                        }
                        .padding(.bottom)
                    
                    if showIPError {
                        Text("Invalid IP address")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.bottom, 5)
                    }
                    
                    // Subnet Mask Input
                    TextField("Subnet Mask", text: $subnetMask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                        .onChange(of: subnetMask) {
                            showSubnetMaskError = !isValidSubnetMask(subnetMask)
                        }
                        .padding(.bottom)
                    
                    if showSubnetMaskError {
                        Text("Invalid subnet mask")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.bottom, 5)
                    }
                }
            }
        }
        .navigationTitle("Router Settings")
    }
    
    // Validate IP Address format
    func isValidIP(_ ip: String) -> Bool {
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        for part in parts {
            guard let number = Int(part), number >= 0 && number <= 255 else {
                return false
            }
        }
        return true
    }
    
    // Validate Subnet Mask format
    func isValidSubnetMask(_ mask: String) -> Bool {
        let validMasks = [
            "255.0.0.0", "255.255.0.0", "255.255.255.0", "255.255.255.128",
            "255.255.255.192", "255.255.255.224", "255.255.255.240",
            "255.255.255.248", "255.255.255.252", "255.255.255.254"
        ]
        return validMasks.contains(mask)
    }
}

#Preview {
    NavigationView {
        RouterView()
    }
}
