//
//  RouterPortsView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct RouterPortsView: View {
    @State var ports: [Port] = [Port(name: "Wan 0", isActive: true), Port(name: "Lan 0", isActive: false)]
    var body: some View {
        HStack {
            ForEach(ports, id: \.self) { i in
                VStack {
                    RJ45PortView(color: .yellow)
                        .frame(width: 50, height: 50)
                    Text("Wan 0")
                }
            }
        }
    }
}

#Preview {
    RouterPortsView()
}

struct Port {
    let name: String
    let isActive: Bool
}
