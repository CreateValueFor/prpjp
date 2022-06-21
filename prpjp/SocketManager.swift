//
//  SocketManager.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/06.
//

import Foundation
import SwiftSocket

public typealias Byte = UInt8

class SwiftSockMine {
    static let mInstance = SwiftSockMine()
    private init(){
        self.addr = "172.20.10.4"
        self.port = Int32(8000)
    }
    
    var addr : String?
    var port : Int32?
    var client : TCPClient?
    
    func InitSocket(address: String, portNum : Int32){
        self.addr = address
        self.port = portNum
        print("소켓 연결 시작 \(address):\(portNum)")
        client = TCPClient(address: address, port: Int32(portNum))
        switch client?.connect(timeout: 10){
        case .success :
            print("소켓 연결 성공")
            guard let data = client?.read(1024 * 10) else {return print("haha")}
            print("수신 내용 \(data)" )
            
            switch client?.send(string: "{'text':'hello','background':{'type':'com.example.flexibledisplaypanel.socket.data.Background.Color','colorType':'BLUE'},'textColor':'RED','fontSize':'LARGE','fontStyle':'NONE','displaySize':'D192X32','location':{'first':3,'second':0},'isReverse':false})"){
            case .success:
                print("전달 성공")
            case .failure(let error):
                print("에러 발생 \(error.localizedDescription)")
            default:
                print("알 수 없는 에러 발생")
            }
        case .failure(let error):
            print("에러발생 \(error)")
        default:
            print("알 수 없는 에러 발생")
        }
//        print(client?.read(1024 * 10))
        
        
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
    
    private func sendRequest(string : String, using client : TCPClient)-> String? {
        appendToTextField(string : "Sending data ...")
        switch client.send(string: string){
        case .success:
            print("success: ")
            return readResponse(from : client)
        case .failure(let error):
            print("failure: ")
            appendToTextField(string : String(describing: error))
            return nil
        }
    }
    private func readResponse(from client: TCPClient)-> String? {
        guard let resposne = client.read(1024*10) else {return nil}
        print(resposne)
        return String(bytes: resposne, encoding: .utf8)
    }
    private func appendToTextField(string : String){
        print(string)
    }
    
}

public enum SocketError: Error {
    case queryFailed
    case connectionClosed
    case connectionTimeout
    case unknownError
}
