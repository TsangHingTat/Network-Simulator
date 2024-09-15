//
//  StatusView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/13/24.
//

import SwiftUI

struct StatusView: View {
    @Binding var deviceStatus: Bool

    var body: some View {
        HStack {
            Text("設備狀態")
            Spacer()
            Image(systemName: "power")
                .foregroundColor(deviceStatus ? .green : .red)
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(
            deviceStatus: .constant(true)
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
