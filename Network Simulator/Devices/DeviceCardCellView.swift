//
//  DeviceCardCellView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct DeviceCardCellView: View {
    @State var title: String
    @State var string: String
    @State var color = Color.black
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.callout)
                
                Spacer()
                
                Text(string)
                    .font(.callout)
                    .foregroundColor(color)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}

#Preview {
    DeviceCardCellView(title: "標題", string: "內容")
        .padding()
}
