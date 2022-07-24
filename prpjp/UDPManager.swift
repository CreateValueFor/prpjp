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
    static var timeTrigger = true
    static var realTime = Timer()
    
    var mysock = SwiftSockMine.mInstance
    
    static func portForEndpoint(_ endpoint: NWEndpoint) -> Array<Any>? {
        switch endpoint {
        case .hostPort(let host, let port):
            return [host,port]
        default:
            return []
        }
    }
    static func checkTimeTrigger() {
        realTime = Timer.scheduledTimer(timeInterval: 1, target: self,
            selector: #selector(updateCounter), userInfo: nil, repeats: true)
        timeTrigger = false
    }
    
    static func startAction(){
        if(self.timeTrigger){
            self.checkTimeTrigger()
        }
        
    }
    
    @objc static func updateCounter(){
        self.sendUDP("hello")
    }
    
    static func sendUDP(_ content: String) {
        print("sendUDP function started")
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
        self.udpConnection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }
    
    static func broadCastUDP() {
        self.startAction()
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
        
        let str = "Hyuns:8000"
        
//        let buf: [UInt8] = Array(str.utf8)
        let packetData = str.data(using: .utf8)
        
        self.udpConnection?.send(content: packetData, completion: NWConnection.SendCompletion.contentProcessed(({ (error) in
                    if let err = error {
                        print("Sending error \(err)")
                    } else {
                        print("Sent successfully")
                    }
                })))
        
        
        
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
    
    static func connectToUDP() {
            // Transmited message:
            let messageToUDP = "Hyuns:8000"
        let queue = DispatchQueue(label: "connection")
        

        self.udpConnection = NWConnection(host:NWEndpoint.Host("255.255.255.255") ,port: NWEndpoint.Port(integerLiteral: 8200), using: .udp)
        self.udpConnection?.start(queue: queue)

            self.udpConnection?.stateUpdateHandler = { (newState) in
                print("This is stateUpdateHandler:")
                switch (newState) {
                    case .ready:
                        print("State: Ready\n")
                        self.sendUDP(messageToUDP)
                    self.startAction()
                        self.receiveUDP()
                    case .setup:
                        print("State: Setup\n")
                    case .cancelled:
                        print("State: Cancelled\n")
                    case .preparing:
                        print("State: Preparing\n")
                    default:
                        print("ERROR! State not defined!\n")
                }
            }

            self.udpConnection?.start(queue: .global())
        }

        static func sendUDP(_ content: Data) {
            self.udpConnection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                if (NWError == nil) {
                    print("Data was sent to UDP")
                } else {
                    print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
                }
            })))
        }

        static func sendStringUDP(_ content: String) {
            let contentToSendUDP = content.data(using: String.Encoding.utf8)
            self.udpConnection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                if (NWError == nil) {
                    print("Data was sent to UDP")
                } else {
                    print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
                }
            })))
        }

        static func receiveUDP() {
            self.udpConnection?.receiveMessage { (data, context, isComplete, error) in
                if (isComplete) {
                    print("Receive is complete")
                    if (data != nil) {
                        let backToString = String(decoding: data!, as: UTF8.self)
                        print("Received message: \(backToString)")
                    } else {
                        print("Data == nil")
                    }
                }
            }
        }
}
