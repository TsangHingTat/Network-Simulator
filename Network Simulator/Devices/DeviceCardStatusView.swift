//
//  DeviceCardStatusView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct DeviceCardStatusView: View {
    @Binding var deviceName: String
    @Binding var symbol: String
    @Binding var deviceStatus: Bool
    
    @State var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    if isEditing {
                        TextField("設備名稱", text: $deviceName, onCommit: {
                            isEditing = false
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                    } else {
                        Text("\(Image(systemName: symbol)) \(deviceName)")
                            .font(.title2)
                            .onTapGesture {
                                isEditing = true
                            }
                    }
                }
                Spacer()
                Image(systemName: "power")
                    .foregroundColor(deviceStatus ? .green : .red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct DeviceCardStatusView_Previews: PreviewProvider {
    @State static var deviceName: String = "路由器"
    @State static var symbol: String = "wifi.router"
    @State static var deviceStatus: Bool = true
    
    static var previews: some View {
        DeviceCardStatusView(deviceName: $deviceName, symbol: $symbol, deviceStatus: $deviceStatus)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
