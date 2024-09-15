//
//  SymbolInfo.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/12/24.
//

import SwiftUI

struct DeviceInfo: Codable, Hashable {
    let name: String
    let icon: String
    let type: String
    let wanQuantity: Int
    let lanQuantity: Int
    let pingSupport: Bool
}

func loadSymbolInfos() -> [DeviceInfo] {
    guard let url = Bundle.main.url(forResource: "devices", withExtension: "json") else {
        fatalError("在 bundle 中找不到 devices.json")
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([DeviceInfo].self, from: data)
    } catch {
        fatalError("解碼 devices.json 失敗：\(error)")
    }
}
