//
//  SymbolInfo.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

// Model for the JSON data
struct DeviceInfo: Codable {
    let name: String
    let icon: String
    let type: String
    let wanQuantity: Int
    let lanQuantity: Int
    let pingSupport: Bool
}

// Function to load JSON data from the app bundle
func loadSymbolInfos() -> [DeviceInfo] {
    guard let url = Bundle.main.url(forResource: "devices", withExtension: "json") else {
        fatalError("Failed to find symbols.json in bundle")
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([DeviceInfo].self, from: data)
    } catch {
        fatalError("Failed to decode symbols.json: \(error)")
    }
}



