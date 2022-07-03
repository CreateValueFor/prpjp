//
//  UDPManager.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/29.
//

import Foundation
import Network

class UDPManager :ObservableObject {
    
    static var udpListener : NWListener?
    static var udpConnection: NWConnection?
    static var backgroundQueueUdpListener = DispatchQueue.main
    static var port : Int32 = 8000
    static var host : String = "172.20.10.4";
    var mysock = SwiftSockMine.mInstance
    
    static func portForEndpoint(_ endpoint: NWEndpoint) -> Array<Any>? {
        switch endpoint {
        case .hostPort(let host, let port):
            return [host,port]
        default:
            return []
        }
    }
    
    
    static func findUDP() {
        print("UPD 실행")
        let params = NWParameters.udp
        udpListener = try? NWListener(using: params, on: 8200)
        udpListener?.service = NWListener.Service.init(type: "_appname._udp")
        self.udpListener?.stateUpdateHandler = { update in
            switch update {
            case .ready:
                print("ready")
            case .setup:
                print("setup")
            case .failed:
                print("failed")
            default:
                print("default update")
            }
        }
        
        self.udpListener?.newConnectionHandler = { connection in
            print("UPD 연결 성공")
            
            
            guard let hostEnum = portForEndpoint(connection.endpoint) else {return }
            
            let host = String(describing: hostEnum[0])
            let port = String(describing: hostEnum[1])
            print("extracted Host is \(host)")
            print("extracted port is \(port)")
            
            
            
            connection.receiveMessage { completeContent, contentContext, isComplete, error in
                guard let data = completeContent,
                      let data2 = contentContext
                        
                else {return}
                
                
                if let string = String(bytes: data, encoding: .utf8) {
                    print("sended UDP PACKET is \(string)" )
                    let text = string.components(separatedBy: ":")
                    if text[0] == "Hyuns"{
                        let port = Int32(text[1]) ?? 0
                        self.port = port
                        self.host = string
//                        mysock.InitSocket(address: host, portNum: port)
                        SwiftSockMine.mInstance.InitSocket(address: host, portNum: port)
                        
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
