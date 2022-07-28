//
//  SocketManager.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/06.
//

import Foundation
import SwiftSocket

public typealias Byte = UInt8


struct data : Codable{
    var text : String
    var background : backgroundData
    var textColor: String
    var fontSize : String
    var fontStyle : String
    var displaySize : String
    var location : locationData
    var isReverse : Bool
}

struct backgroundData : Codable {
    var type: String
    var colorType : String
}
struct locationData  : Codable {
    var first : Int
    var second : Int
}


class SwiftSockMine {
    static let mInstance = SwiftSockMine()
    private init(){
        self.addr = "172.20.10.4"
        self.port = Int32(8080)
    }
    
    var addr : String?
    var port : Int32?
    var client : TCPClient?
    
    var server : TCPServer?
    
    var acceptClient: [TCPClient] = []
    
    var readingWorkItem: DispatchWorkItem? = nil
    var readingQueue = DispatchQueue(label: "com.socket.wating")
    
    func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
    
    func echoService(client: TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")
        
        let result = client.send(string: "1")
        print(">>> accept client send result = \(String(describing: result))")
        
//        guard let d = client.read(1024*10) else {
//            print("function stopped by client's null message")
//            return
//        }
//        let message = String(bytes: d, encoding: .utf8)
//        print("client sended \(String(describing: message))")
        
        //client.send(data: d)
        //client.close()
    }
    
    
    func InitSocket(address: String, portNum : Int32){
        self.addr = address
        self.port = portNum
        
        print(">>> server")
        print("소켓 연결 시작 \(address):\(portNum)")
        let server = TCPServer(address: address, port: portNum)
        self.server = server

        switch server.listen() {
        case .success:
            while true {
                if let client = server.accept() {
                    self.acceptClient.append(client)
                    echoService(client: client)
                    print(">>> client connect")
                } else {
                    print(">>> accept error")
                }
            }
        case .failure(let error):
            print(">>> listen error = \(error.localizedDescription)")
        }
        
        
//        print(">>> client")
//        let client = TCPClient(address: address, port: portNum)
//        self.client = client
//
//        switch client.connect(timeout: 10) {
//        case .success:
//            print("소켓 연결 성공")
//
//            guard let data = client.read(1024*10) else { return }
//            if let response = String(bytes: data, encoding: .utf8) {
//                print(">>> read response = \(response)")
//                _ = client.send(string: "success")
//            }
//
//            self.watingResponse(client)
//
//        case .failure(let error):
//            print("에러발생 \(error.localizedDescription)")
//        }
        
//                print(client?.read(1024 * 10))
    }
    
    func watingResponse(_ client: TCPClient){
        let readingWorkItem = DispatchWorkItem {
            guard let item = self.readingWorkItem else { return }
            
            // read incoming characters one at a time and add to message
            while !item.isCancelled {
                guard let read = client.read(1024*10, timeout: 10) else { continue }
                let message = String(bytes: read, encoding: .utf8)
                print("read message = \(String(describing: message))")
                _ = client.send(string: "success")
                
                self.watingResponse(client)
            }
        }
        self.readingQueue.async(execute: readingWorkItem)
        self.readingWorkItem = readingWorkItem
    }
    
    func send(text: String, background: String, color :  String, fontSize: String, fontStyleBold : String, resolution : DISPLAY_RESOLUTION ) {
        let backgroundData = backgroundData(type: "com.example.flexibledisplaypanel.socket.data.Background.Color", colorType: background)
        let locationData = locationData(first: 0, second: 0)
        
        let data = data(text: text, background: backgroundData, textColor: color, fontSize: fontSize, fontStyle: fontStyleBold, displaySize: resolution.text, location: locationData, isReverse: false)
        
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            
            //            if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8){
            //                print(jsonString)
            //            }
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {return}
            
            for client in self.acceptClient {
                let result = self.sendRequest(string: jsonString, using: client)
                print(">>> accept client send result = \(String(describing: result))")
            }
            
            //            sendRequest(string: "hello\nasdlfkj", using: client!)
            //            connection!.send(content: jsonData, completion: .contentProcessed({ sendError in
            //                if let error = sendError {
            //                    NSLog("Unable to process and send the data: \(error)")
            //                } else {
            //                    NSLog("Data has been sent")
            //                    connection!.receiveMessage { (data, context, isComplete, error) in
            //                        guard let myData = data else { return }
            //                        NSLog("Received message: " + String(decoding: myData, as: UTF8.self))
            //                    }
            //                }
            //            }))
        }catch{
            print(error)
        }
    }
    
    func sendMessage(msg:String){
        guard let client = client else {return }
        
        switch client.connect(timeout: 10){
        case .success:
            appendToTextField(string : "Connected to host \(client.address)")
            let newMsg : String = msg + "\n\n"
            
            if let response = sendRequest(string : newMsg, using: client){
                appendToTextField(string : "Reponse: \(response)")
            }
        case .failure(let error):
            appendToTextField(string : String(describing: error))
            
            
        }
    }
    
    //    private func sendRequest(string : String, using client : TCPClient)-> String? {
    //        appendToTextField(string : "Sending data ...")
    //        switch client.send(string: string){
    //        case .success:
    //            print("success: ")
    //            return readResponse(from : client)
    //        case .failure(let error):
    //            print("failure: ")
    //            appendToTextField(string : String(describing: error))
    //            return nil
    //        }
    //    }
    //    private func readResponse(from client: TCPClient)-> String? {
    //        guard let resposne = client.read(1024*10) else {return nil}
    //        print(resposne)
    //        return String(bytes: resposne, encoding: .utf8)
    //    }
    //    private func appendToTextField(string : String){
    //        print(string)
    //    }
    //
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        appendToTextField(string: "Sending data ... \(string)")
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            print(error.localizedDescription)
            print("전달 에러 발생")
            //            appendToTextField(string: String(dexscribing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        print("readResponse")
        guard let response = client.read(1024*10) else { return nil }
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String) {
        print(string)
        
    }
    
}

public enum SocketError: Error {
    case queryFailed
    case connectionClosed
    case connectionTimeout
    case unknownError
}
