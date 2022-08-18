//
//  Notification.Name+.swift
//  prpjp
//
//  Created by mykim on 2022/08/17.
//

import Foundation

extension Notification.Name {
  
    /// TCP로 연결이 변경 되면 Notification 발생
    public static let tcpDidChangeConnectedState = Notification.Name(rawValue: "tcp.did.change.connected.state")
    
}
