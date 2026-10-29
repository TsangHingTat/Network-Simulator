//
//  DeviceCardCellView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI
import UIKit

struct DeviceCardCellView: View {
    var icon: String? = nil
    var title: String
    var string: String
    var color: Color = .primary
    var isCopyable: Bool = false
    
    @State private var copied: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(string)
                .font(.subheadline.weight(.medium))
                .foregroundColor(color)
                .textSelection(.enabled)

            if isCopyable && !string.isEmpty && string != "none" {
                Button {
                    UIPasteboard.general.string = string
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        copied = false
                    }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .foregroundColor(copied ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    VStack {
        DeviceCardCellView(icon: "network", title: "設備 MAC 地址", string: "02:A1:B2:C3:D4:E5", isCopyable: true)
        DeviceCardCellView(icon: "globe", title: "連接狀態", string: "網際網路連接", color: .green)
    }
    .padding()
}
