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
        VStack(alignment: .leading) {
            Text("重新命名設備")
            TextField("輸入設備名稱", text: $deviceName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom)
        }
    }
}

struct NameView_Previews: PreviewProvider {
    static var previews: some View {
        NameView(
            deviceName: .constant("設備名稱")
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
