//
//  ConnectionType.swift
//  Network Simulator
//
//  Created by HingTatTsang on 9/14/24.
//

import Foundation
import SwiftUI

enum ConnectionType {
    case restrictedConnection
    case internetConnection
    case localConnection
    case peerToPeerConnection
    case noConnection

    var sfSymbol: String {
        switch self {
        case .restrictedConnection:
            return "lock.shield"
        case .internetConnection:
            return "globe"
        case .localConnection:
            return "house"
        case .peerToPeerConnection:
            return "person.2"
        case .noConnection:
            return "xmark.circle"
        }
    }

    var description: String {
        switch self {
        case .restrictedConnection:
            return "受限連接"
        case .internetConnection:
            return "網際網路連接"
        case .localConnection:
            return "本地連接"
        case .peerToPeerConnection:
            return "點對點連接"
        case .noConnection:
            return "無連接"
        }
    }
}

func getColorFromInternetType(input: ConnectionType) -> Color {
    switch input {
    case .internetConnection:
        return .green
    case .localConnection:
        return .yellow
    case .restrictedConnection:
        return .orange
    case .peerToPeerConnection:
        return .yellow
    case .noConnection:
        return .red
    }
}
