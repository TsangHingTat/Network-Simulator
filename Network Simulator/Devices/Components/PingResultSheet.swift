//
//  PingResultSheet.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct PingResultSheet: View {
    @Binding var result: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            Text("Ping 結果")
                .font(.headline)
                .padding()

            Divider()
                .padding(.horizontal)

            Text(result)
                .padding()
                .multilineTextAlignment(.leading)

            Spacer()

            Button("關閉") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var previewResult = "Ping 127.0.0.1: bytes=32 time<1ms TTL=64"

    return PingResultSheet(result: $previewResult)
}
