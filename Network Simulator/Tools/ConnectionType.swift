//
//  ConnectionType.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import SwiftUI

enum ConnectionType: String, CaseIterable, Codable, Sendable {
    case internetConnection = "internet"
    case restrictedConnection = "restricted"
    case localConnection = "local"
    case peerToPeerConnection = "p2p"
    case noConnection = "none"
    case offline = "offline"

    var sfSymbol: String {
        switch self {
        case .internetConnection:
            return "globe"
        case .restrictedConnection:
            return "lock.shield"
        case .localConnection:
            return "house"
        case .peerToPeerConnection:
            return "person.2"
        case .noConnection:
            return "bolt.horizontal.circle"
        case .offline:
            return "power.circle"
        }
    }

    var description: String {
        switch self {
        case .internetConnection:
            return "網際網路連接"
        case .restrictedConnection:
            return "受限連接 (防火牆)"
        case .localConnection:
            return "局域網連接 (無外網)"
        case .peerToPeerConnection:
            return "點對點連接"
        case .noConnection:
            return "無連接 (未配置 IP)"
        case .offline:
            return "設備已關機"
        }
    }

    var color: Color {
        switch self {
        case .internetConnection:
            return .green
        case .restrictedConnection:
            return .orange
        case .localConnection:
            return .blue
        case .peerToPeerConnection:
            return .purple
        case .noConnection:
            return .red
        case .offline:
            return .gray
        }
    }
}

// Backward compatibility helper
func getColorFromInternetType(input: ConnectionType) -> Color {
    return input.color
}
