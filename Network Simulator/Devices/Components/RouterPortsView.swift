//
//  RouterPortsView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct RouterPortsView: View {
    @State var ports: [Port]

    let gridItems = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 20) {
            ForEach(ports, id: \.self) { port in
                VStack {
                    RJ45PortView(color: port.isActive ? .green : .gray)
                        .frame(width: 50, height: 50)

                    Text(port.name)
                }
            }
        }
        .padding()
        .background(isDarkMode() ? Color.black : Color.white)
        .cornerRadius(20)
    }
}

struct Port: Hashable {
    let name: String
    let isActive: Bool
}

#Preview {
    RouterPortsView(ports: [
        Port(name: "Wan 0", isActive: true),
        Port(name: "Lan 0", isActive: false),
        Port(name: "Lan 1", isActive: false),
        Port(name: "Lan 2", isActive: false),
        Port(name: "Lan 3", isActive: false),
        Port(name: "Lan 4", isActive: true),
        Port(name: "Lan 5", isActive: true)
    ])
    .padding()
}
