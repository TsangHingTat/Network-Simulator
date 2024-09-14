//
//  SymbolView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

// View for a symbol in the list
struct SymbolView: View {
    var symbol: Symbol
    var isSelected: Bool
    var deleteAction: () -> Void
    
    var body: some View {
        HStack {
            Color.clear
                .frame(width: 70, height: 50)
                .overlay() {
                    Text(Image(systemName: symbolIcon))
                        .font(.largeTitle)
                        .foregroundColor(isSelected ? .green : .blue)
                }
            Text(symbolLabel)
            Spacer()
        }
        .padding(10)
        .background(isSelected ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(10)
        .contextMenu {
            Button(action: deleteAction) {
                Label("Delete", systemImage: "trash")
            }
        }
        .padding(.horizontal)
    }
    
    var symbolLabel: String {
        symbolInfo?.name ?? "Unknown"
    }
    
    var symbolIcon: String {
        symbolInfo?.icon ?? "questionmark"
    }
    
    var symbolInfo: SymbolInfo? {
        return loadSymbolInfos().first { $0.type == symbol.type }
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SymbolView(
                symbol: Symbol(id: UUID(), type: "router"),
                isSelected: true,
                deleteAction: {
                    // Handle delete action
                    print("Symbol deleted")
                }
            )
            SymbolView(
                symbol: Symbol(id: UUID(), type: "tv"),
                isSelected: true,
                deleteAction: {
                    // Handle delete action
                    print("Symbol deleted")
                }
            )
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
