//
//  UDPManager.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/29.
//

import Foundation
import Network

class UDPManager {
    private let defaultIP: String = "192.168.43.84"
    var connection: NWConnection?
    static var udpListener : NWListener?
    static var udpConnection: NWConnection?
    static var backgroundQueueUdpListener = DispatchQueue.main
    
    static func portForEndpoint(_ endpoint: NWEndpoint) -> NWEndpoint.Host? {
        switch endpoint {
        case .hostPort(let host, let port):
            return host
        default:
            return nil
        }
    }
    
    
    static func findUDP() {
        let params = NWParameters.udp
        udpListener = try? NWListener(using: params, on: 8200)
        udpListener?.service = NWListener.Service.init(type: "_appname._udp")
        self.udpListener?.stateUpdateHandler = { update in
            switch update {
            case .failed:
                print("failed")
            default:
                print("default update")
            }
        }
        
        self.udpListener?.newConnectionHandler = { connection in
            
            
            guard let hostEnum = portForEndpoint(connection.endpoint) else {return }
            let host = String(describing: hostEnum)
            print("extracted Host is \(host)")
            
            
            connection.receiveMessage { completeContent, contentContext, isComplete, error in
                guard let data = completeContent,
                      let data2 = contentContext
                        
                else {return}
                
                
                if let string = String(bytes: data, encoding: .utf8) {
                    print("sended UDP PACKET is \(string)" )
                    let text = string.components(separatedBy: ":")
                    if text[0] == "Hyuns"{
                        let port = Int32(text[1]) ?? 0
//                        mysock.InitSocket(address: host, portNum: port)
                        
                    }
                } else {
                    print("not a valid UTF-8 sequence")
                }
                
                
            }
            
            
            //            createConnection(connection: connection)
            self.udpConnection = connection
            self.udpConnection?.start(queue: .global())
            
            self.udpListener?.cancel()
        }
        udpListener?.start(queue: self.backgroundQueueUdpListener)
    }
}
