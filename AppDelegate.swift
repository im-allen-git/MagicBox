//
//  AppDelegate.swift
//  MagicBox
//
//  Created by admin on 2020/7/31.
//  Copyright © 2020年 Kairong. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var espTouchNetworkDelegate = ESPTouchNetworkDelegate()
    private var reachability:Reachability!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        espTouchNetworkDelegate.tryOpenNetworkPermission()
        FirebaseApp.configure()
        if #available(iOS 11, *) {  //有安全区（刘海）的是true， 正常的是false
              guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                WebHost.isFullScreen = false
                return false
              }
              
              if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                  print(unwrapedWindow.safeAreaInsets)
                WebHost.isFullScreen = true
              }
        }
        else{
            WebHost.isFullScreen = false
        }
        print("WebHost.isFullScreen")
        print(WebHost.isFullScreen)
        
        return true
    }
    
    
    var blockRotation: UIInterfaceOrientationMask = .portrait{
        didSet{
            if blockRotation.contains(.portrait){
                //强制设置成竖屏
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }else{
                //强制设置成横屏
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                
            }
        }
    }
    
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return blockRotation
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let vc = self.window?.rootViewController as? ViewController{
            vc.wifiInfo["ssid"] = espTouchNetworkDelegate.fetchSsid()
            vc.wifiInfo["bssid"] = espTouchNetworkDelegate.fetchBssid()
            
            print("ssid")
            print(espTouchNetworkDelegate.fetchSsid())
            print("bssid")
            print(espTouchNetworkDelegate.fetchBssid())
        }
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .flagsChanged, object: Network.reachability)
    }
    
    @objc func reachabilityChanged(notification:Notification) {
        let reachability = notification.object as! Reachability
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Network not reachable")
        }
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
        
}

extension NSURLRequest{
    static func allowsAnyHTTPSCertificateForHost(host:String) ->Bool{
        return true
    }
}

