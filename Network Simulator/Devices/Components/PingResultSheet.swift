//
//  PingResultSheet.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI
import UIKit

struct PingResultSheet: View {
    @Binding var result: String
    @Environment(\.dismiss) private var dismiss
    @State private var copied: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView {
                    Text(result.isEmpty ? "尚無 Ping 測試輸出" : result)
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .textSelection(.enabled)
                }
                .background(Color.black.opacity(0.95))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Ping 診斷終端")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("關閉") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        UIPasteboard.general.string = result
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            copied = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            Text(copied ? "已複製" : "複製結果")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var previewResult = """
    PING 192.168.1.1 (192.168.1.1) from 192.168.1.10: 56 data bytes
    64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=0.421 ms
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.389 ms
    64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.512 ms
    64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.405 ms

    --- 192.168.1.1 ping 統計資料 ---
    4 packets transmitted, 4 received, 0% packet loss
    round-trip min/avg/max = 0.389/0.432/0.512 ms
    """

    PingResultSheet(result: $previewResult)
}
