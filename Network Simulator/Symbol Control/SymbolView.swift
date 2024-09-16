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
    
    var isChild = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isChild {
                    Image(systemName: "arrow.turn.down.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                HStack {
                    Color.clear
                        .frame(width: 45, height: 45)
                        .overlay() {
                            Text(Image(systemName: symbol))
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                        }
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.title3)
                        ZStack {
                            Text(mac == "none" ? "No MAC Address   " : mac)
                                .font(.footnote)
                            Text(mac == "none" ? "00:00:00:00:00:00" : mac)
                                .font(.footnote)
                                .hidden()
                        }
                    }
                }
                .frame(minWidth: 190)
                .padding(9)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
            
        }
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView(symbol: "star.fill", name: "Device", mac: "00:1A:2B:3C:4D:5E")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
