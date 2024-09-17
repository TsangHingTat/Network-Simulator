//
//  MapView.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/15/24.
//

import SwiftUI

struct MapView: View {
    @State var deviceData: DeviceData
    @State var showMap = true
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView(.horizontal) {
                    if showMap {
                        DeviceView(
                            device: $deviceData,
                            showMap: $showMap
                        )
                    } else {
                        Text("Loading...")
                            .onAppear() {
                                showMap.toggle()
                            }
                    }
                }
            }
            .navigationTitle("網路建構器")

        }
        .navigationViewStyle(.stack)
    }


}



