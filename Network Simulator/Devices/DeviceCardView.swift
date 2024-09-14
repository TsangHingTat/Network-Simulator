//
//  RouterView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/11/24.
//

import SwiftUI

struct RouterView: View {
    @State var deviceName: String = "Router"
    @State var deviceStatus: Bool = false
    @State var network_v1 = NetworkV1()
    
    var body: some View {
        List {
            Section {
                // Device Status Section
                StatusView(deviceStatus: $deviceStatus)
            }
            
            Section {
                // Rename Device Section
                NameView(deviceName: $deviceName)
            }
            
            Section {
                // DHCP Settings Section
                DHCPView(network_v1: $network_v1)
            }
        }
        .navigationTitle("Router Settings")
    }
    
}

#Preview {
    NavigationView {
        RouterView()
    }
}
