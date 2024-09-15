//
//  RJ45PortView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

struct RJ45PortView: View {
    @State var color: Color = .black

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: geometry.size.width * 0.025)
                    .stroke(lineWidth: geometry.size.width * 0.05)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(color)

                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: geometry.size.width * 0.75, height: geometry.size.height * 0.416)
                            .cornerRadius(geometry.size.width * 0.025)
                            .foregroundColor(color)

                        VStack {
                            Spacer()
                                .frame(height: geometry.size.height * 0.25)
                            Rectangle()
                                .frame(width: geometry.size.width * 0.583, height: geometry.size.height * 0.416)
                                .cornerRadius(geometry.size.width * 0.025)
                                .foregroundColor(color)
                        }

                        VStack {
                            Spacer()
                                .frame(height: geometry.size.height * 0.375)
                            Rectangle()
                                .frame(width: geometry.size.width * 0.416, height: geometry.size.height * 0.416)
                                .cornerRadius(geometry.size.width * 0.025)
                                .foregroundColor(color)
                        }
                    }
                    Spacer()
                        .frame(height: geometry.size.height * 0.2)
                }

                VStack(spacing: 0) {
                    HStack(spacing: geometry.size.width * 0.058) {
                        ForEach(0..<8) { _ in
                            Rectangle()
                                .frame(width: geometry.size.width * 0.025, height: geometry.size.height * 0.25)
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                        .frame(height: geometry.size.height * 0.25)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .foregroundColor(.black)
        }
    }
}

#Preview {
    let colors: [Color] = [.black, .yellow, .red, .green]
    VStack {
        ForEach(colors, id: \.self) { i in
            RJ45PortView(color: i)
                .frame(width: 100, height: 100)
                .padding()
        }
    }
}
