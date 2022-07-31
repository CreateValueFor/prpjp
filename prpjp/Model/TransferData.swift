//
//  TransferData.swift
//  prpjp
//
//  Created by mykim on 2022/07/30.
//

import Foundation

struct TransferData: Codable {
    var text: String
    var background: BackgroundData
    var textColor: String
    var fontSize: String
    var fontStyle: String
    var displaySize: String
    var location: LocationData
    var isReverse: Bool
}

struct BackgroundData: Codable {
    var type: String
    var colorType: String
}
struct LocationData: Codable {
    var first: Int
    var second: Int
}
