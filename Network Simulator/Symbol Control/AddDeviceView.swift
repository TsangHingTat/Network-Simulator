//
//  AddSymbolView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

// Sheet view for adding a new device
struct AddSymbolSheet: View {
    var addSymbolAction: (String) -> Void
    let deviceInfos: [DeviceInfo]

    var body: some View {
        NavigationView {
            List {
                ForEach(deviceInfos, id: \.type) { info in
                    Button(action: { addSymbolAction(info.type) }) {
                        Label(info.name, systemImage: info.icon)
                    }
                }
            }
            .navigationTitle("Add a device")
            .navigationBarItems(trailing: Button("Close") {
                // Close the sheet
                addSymbolAction("") // Dummy action to dismiss
            })
        }
    }
}


