//
//  AddDeviceView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

struct AddDeviceSheet: View {
    let deviceInfos: [DeviceInfo] = loadSymbolInfos()
    var addDeviceAction: (String) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(deviceInfos, id: \.type) { info in
                    Button(action: { addDeviceAction(info.type) }) {
                        Label(info.name, systemImage: info.icon)
                    }
                }
            }
            .navigationTitle("添加設備")
            .navigationBarItems(trailing: Button("關閉") {
                addDeviceAction("")
            })
        }
    }
}
