//
//  RJ45PortIcon.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct RJ45PortView: View {
    var color: Color = .primary
    var isConnected: Bool = false
    var isLinkActive: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height

            ZStack {
                // Outer Port Bezel
                RoundedRectangle(cornerRadius: w * 0.12)
                    .fill(Color(.tertiarySystemFill))
                    .overlay(
                        RoundedRectangle(cornerRadius: w * 0.12)
                            .stroke(color.opacity(0.8), lineWidth: max(1.5, w * 0.05))
                    )

                // Inner Jack Cavity
                VStack(spacing: 0) {
                    // Top latch notch
                    RoundedRectangle(cornerRadius: w * 0.04)
                        .fill(Color(.systemBackground))
                        .frame(width: w * 0.44, height: h * 0.22)

                    // Main socket area
                    RoundedRectangle(cornerRadius: w * 0.06)
                        .fill(Color.black.opacity(0.85))
                        .frame(width: w * 0.78, height: h * 0.48)
                        .overlay(
                            // 8 Gold Contact Pins
                            HStack(spacing: w * 0.04) {
                                ForEach(0..<8, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color(red: 0.85, green: 0.70, blue: 0.25))
                                        .frame(width: max(1, w * 0.04), height: h * 0.22)
                                }
                            }
                        )
                }

                // LED Link Indicator Dot at top right
                Circle()
                    .fill(isLinkActive ? Color.green : (isConnected ? Color.orange : Color.gray.opacity(0.4)))
                    .frame(width: w * 0.18, height: h * 0.18)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                    )
                    .shadow(color: isLinkActive ? Color.green.opacity(0.8) : Color.clear, radius: 3)
                    .position(x: w * 0.82, y: h * 0.2)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    HStack(spacing: 20) {
        RJ45PortView(color: .gray, isConnected: false, isLinkActive: false)
            .frame(width: 60, height: 60)
        RJ45PortView(color: .blue, isConnected: true, isLinkActive: false)
            .frame(width: 60, height: 60)
        RJ45PortView(color: .green, isConnected: true, isLinkActive: true)
            .frame(width: 60, height: 60)
    }
    .padding()
}
