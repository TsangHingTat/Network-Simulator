//
//  SymbolView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

struct SymbolView: View {
    var symbol: String
    var name: String
    var mac: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Color.clear
                    .frame(width: 50, height: 50)
                    .overlay() {
                        Text(Image(systemName: symbol))
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.title3)
                    Text(mac)
                        .font(.footnote)
                }
            }
            .padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView(symbol: "star.fill", name: "Sample Device", mac: "00:1A:2B:3C:4D:5E")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
