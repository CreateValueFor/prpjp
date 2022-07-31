//
//  SocketClientManager.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/06.
//

import Foundation
import SwiftSocket

public typealias Byte = UInt8

final public class SocketClientManager {
    
    public static let shared = SocketClientManager()
    
    private var client: TCPClient?
    private var readingWorkItem: DispatchWorkItem? = nil
    private let readingQueue = DispatchQueue(label: "com.socket.waiting", qos: .userInitiated, attributes: .concurrent)
    
    func run(address: String, port: Int32) {
        let client = TCPClient(address: address, port: port)
        self.client = client

        switch client.connect(timeout: 10) {
        case .success:
            print("소켓 연결 성공")
            self.watingResponse(client)
        case .failure(let error):
            print("에러발생 \(error.localizedDescription)")
        }
    }
    
    func watingResponse(_ client: TCPClient){
        let readingWorkItem = DispatchWorkItem { [weak self] in
            guard let item = self?.readingWorkItem else { return }
            
            // read incoming characters one at a time and add to message
            while !item.isCancelled {
                guard let read = client.read(4096, timeout: 10) else { continue }
                let message = String(bytes: read, encoding: .utf8)
                print("read message = \(String(describing: message))")
                self?.watingResponse(client)
            }
        }
        self.readingQueue.asyncAfter(deadline: .now() + .milliseconds(500), execute: readingWorkItem)
        self.readingWorkItem = readingWorkItem
    }
}
