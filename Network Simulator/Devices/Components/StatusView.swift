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
            Label("設備供電狀態", systemImage: "power")
            Spacer()
            Toggle("", isOn: $deviceStatus)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    @Previewable @State var status = true
    StatusView(deviceStatus: $status)
        .padding()
}
