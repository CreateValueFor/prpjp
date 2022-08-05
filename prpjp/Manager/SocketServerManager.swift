//
//  SocketServerManager.swift
//  prpjp
//
//  Created by mykim on 2022/07/30.
//

import Foundation
import Socket
import Dispatch
import UIKit
import SwiftUI

final public class SocketServerManager {
    
    public static let shared = SocketServerManager()
    
    private var server: EchoServer?
    
    init() {
        
    }
    
    func run() {
        let port = 8000
        let server = EchoServer(port: port)
        self.server = server
        print("Swift Echo Server Sample")
        print("Connect with a command line window by entering 'telnet ::1 \(port)'")
        server.run()
    }
    
    func send(text: String, background: String, color :  String, fontSize: String, fontStyleBold : String, resolution : String) {
        
        print(">>> send function started")
        let backgroundData = BackgroundData(type: "com.example.flexibledisplaypanel.socket.data.Background.Color",
                                            colorType: background)
        let locationData = LocationData(first: 0, second: 0)
        
        let data = TransferData(text: text,
                                background: backgroundData,
                                textColor: color,
                                fontSize: fontSize,
                                fontStyle: fontStyleBold,
                                displaySize: resolution,
                                location: locationData,
                                isReverse: false)
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
            self.server?.sendRequest(string: "2")
            
            self.server?.sendRequest(string: jsonString)

            
        }catch{
            print(error)
        }
    }
    
    func send(text: String, background: UIImage, backgroundPath : String, color :  String, fontSize: String, fontStyleBold : String, resolution : String) {
        
        print(">>> send function started")
        guard let imageArray = background.jpegData(compressionQuality: 0.6) else { return }
        
        
        let backgroundData = BackgroundImageData(type: "com.example.flexibledisplaypanel.socket.data.Background.Image",
                                                 uriPath: backgroundPath, name : backgroundPath)
        let locationData = LocationData(first: 0, second: 0)
        
        let data = TransferImageData(text: text,
                                background: backgroundData,
                                textColor: color,
                                fontSize: fontSize,
                                fontStyle: fontStyleBold,
                                displaySize: resolution,
                                location: locationData,
                                isReverse: false)
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
            self.server?.sendRequest(string: "3")
            self.server?.sendRequest(string: jsonString)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
              // 1초 후 실행될 부분
                self.server?.sendRequest(data: imageArray)
            }
            
        }catch{
            print(error)
        }
    }
}

class EchoServer {
    
    func sendRequest(string: String) {
        print(connectedSockets)
        let sockets = connectedSockets.enumerated().map { $1.value }
        sockets.forEach {
            print(string)
            _ = try? $0.write(from: string)
        }
    }
    
    func sendRequest(data: Data) {
        print(connectedSockets)
        let sockets = connectedSockets.enumerated().map { $1.value }
        sockets.forEach {
            _ = try? $0.write(from: data)
        }
    }
    
    static let quitCommand: String = "QUIT"
    static let shutdownCommand: String = "SHUTDOWN"
    static let bufferSize = 4096 * 1024
    
    let port: Int
    var listenSocket: Socket? = nil
    var continueRunningValue = true
    var connectedSockets = [Int32: Socket]()
    let socketLockQueue = DispatchQueue(label: "com.kitura.serverSwift.socketLockQueue")
    var continueRunning: Bool {
        set(newValue) {
            socketLockQueue.sync {
                self.continueRunningValue = newValue
            }
        }
        get {
            return socketLockQueue.sync {
                self.continueRunningValue
            }
        }
    }

    init(port: Int) {
        self.port = port
    }
    
    deinit {
        // Close all open sockets...
        for socket in connectedSockets.values {
            socket.close()
        }
        self.listenSocket?.close()
    }
    
    func run() {
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async { [unowned self] in
            
            do {
                // Create an IPV4 socket...
                try self.listenSocket = Socket.create(family: .inet)
                
                guard let socket = self.listenSocket else {
                    
                    print("Unable to unwrap socket...")
                    return
                }
                
                print(">>> address = \(String(describing: socket.signature?.address))")
                
                try socket.listen(on: self.port)
                
                print("Listening on port: \(socket.listeningPort)")
                
                repeat {
                    let newSocket = try socket.acceptClientConnection()
                    
                    print("Accepted connection from: \(newSocket.remoteHostname) on port \(newSocket.remotePort)")
                    print("Socket Signature: \(String(describing: newSocket.signature?.description))")
                    
                    self.addNewConnection(socket: newSocket)
                    
                } while self.continueRunning
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error...")
                    return
                }
                
                if self.continueRunning {
                    
                    print("Error reported:\n \(socketError.description)")
                    
                }
            }
        }
    }
    
    func addNewConnection(socket: Socket) {
        
        // Add the new socket to the list of connected sockets...
        socketLockQueue.sync { [unowned self, socket] in
            self.connectedSockets[socket.socketfd] = socket
        }
        
        // Get the global concurrent queue...
        let queue = DispatchQueue.global(qos: .default)
        
        // Create the run loop work item and dispatch to the default priority global queue...
        queue.async { [unowned self, socket] in
            
            var shouldKeepRunning = true
            
            var readData = Data(capacity: EchoServer.bufferSize)
            
            do {
                // Write the welcome string...
                try socket.write(from: "1")
//                try socket.write(from: "Hello, type 'QUIT' to end session\nor 'SHUTDOWN' to stop server.\n")
                
                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    
                    if bytesRead > 0 {
                        guard let response = String(data: readData, encoding: .utf8) else {
                            
                            print("Error decoding response...")
                            readData.count = 0
                            break
                        }
                        if response.hasPrefix(EchoServer.shutdownCommand) {
                            
                            print("Shutdown requested by connection at \(socket.remoteHostname):\(socket.remotePort)")
                            
                            // Shut things down...
                            self.shutdownServer()
                            
                            return
                        }
                        print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")
                        let reply = "Server response: \n\(response)\n"
                        try socket.write(from: reply)
                        
                        if (response.uppercased().hasPrefix(EchoServer.quitCommand) || response.uppercased().hasPrefix(EchoServer.shutdownCommand)) &&
                            (!response.hasPrefix(EchoServer.quitCommand) && !response.hasPrefix(EchoServer.shutdownCommand)) {
                            
                            try socket.write(from: "If you want to QUIT or SHUTDOWN, please type the name in all caps. 😃\n")
                        }
                        
                        if response.hasPrefix(EchoServer.quitCommand) || response.hasSuffix(EchoServer.quitCommand) {
                            
                            shouldKeepRunning = false
                        }
                    }
                    
                    if bytesRead == 0 {
                        
                        shouldKeepRunning = false
                        break
                    }
                    
                    readData.count = 0
                    
                } while shouldKeepRunning
                
                print("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                socket.close()
                
                self.socketLockQueue.sync { [unowned self, socket] in
                    self.connectedSockets[socket.socketfd] = nil
                }
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                if self.continueRunning {
                    print("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
    
    func shutdownServer() {
        print("\nShutdown in progress...")

        self.continueRunning = false
        
        // Close all open sockets...
        for socket in connectedSockets.values {
            
            self.socketLockQueue.sync { [unowned self, socket] in
                self.connectedSockets[socket.socketfd] = nil
                socket.close()
            }
        }
        
        DispatchQueue.main.sync {
            exit(0)
        }
    }
}
