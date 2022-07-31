//
//  AppDelegate.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/05.
//

import Foundation
import UIKit

class MyAppDelegate : NSObject, UIApplicationDelegate {
    let serverManager: SocketServerManager = SocketServerManager.shared
    let clientManager: SocketClientManager = SocketClientManager.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
}
