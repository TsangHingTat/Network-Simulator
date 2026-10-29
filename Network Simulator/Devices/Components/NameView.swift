//
//  NameView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/13/24.
//

import SwiftUI

struct NameView: View {
    @Binding var deviceName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("重新命名設備")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("輸入設備名稱", text: $deviceName)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    @Previewable @State var name = "路由器 1"
    NameView(deviceName: $name)
        .padding()
}
