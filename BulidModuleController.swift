//
//  BulidModuleController.swift
//  MagicBox
//
//  Created by admin on 2020/8/20.
//  Copyright © 2020年 Kairong. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class BulidModuleController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
   
    
    let kAppdelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    var screenWidth:CGFloat = 0;
    var screenHeight:CGFloat = 0;
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        
        let userScript = WKUserScript(source: "sendReq()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(userScript)
        configuration.userContentController.add(
            self as WKScriptMessageHandler,
            name: "callbackHandler"
        )
        
        //监听js
        configuration.userContentController.add(self, name: "callbackHandle")
        configuration.userContentController.add(self, name: "callbackHandle2")
        configuration.userContentController.add(self, name: "jumpPage")
        configuration.userContentController.add(self, name: "logMessage")
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        var webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isTranslucent = false
        
        super.viewDidLoad()
        // title = "WebViewJS交互Demo"
        view.backgroundColor = .white
        view.addSubview(webView)
        
//        let oriention = UIInterfaceOrientation.landscapeRight // 设置屏幕为横屏
//        UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
//        UIViewController.attemptRotationToDeviceOrientation()
//        //更新视图大小
//        self.view.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        screenWidth = self.view.frame.width;      //the main screen size of width;
        screenHeight = self.view.frame.height;    //the main screen size of height;
        
        print("screenWidth:")
        print(screenWidth)
        print("screenHeight:")
        print(screenHeight)
        
        self.webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width )
        
        print("width:" + UIScreen.main.bounds.width.description)
        print("height:" + UIScreen.main.bounds.height.description)
        
        loadHtml(htmlUrl: HtmlConfig.MYMODULE_HTML)
    }
    
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
        case "callbackHandle":
            //单个参数
            //print("\(message.body)")
            break
        case "callbackHandle2":
            //多个参数
            if let dic = message.body as? NSDictionary {
                let key: String = (dic["key"] as AnyObject).description
                let value: String = (dic["value"] as AnyObject).description
                
                //print("key: \(key)")
                //print("value: \(value)")
            }
            break
        case "jumpPage":
            let code = message.body
            checkAndJump(code: code as! String)
            break
        case "logMessage":
            // print(message.body)
            break
        default: break
        }
        //print(message.body)
    }
    
    
    func checkAndJump(code : String){

        //设置竖屏
        kAppdelegate?.blockRotation = .portrait
        // navigationController?.popViewController(animated: true)
        //跳转
        let firstView = ViewController()
        //取目标页面的一个变量进行赋值，以属性的方式进行传值。
        firstView.message = code
        //跳转
        self.present(firstView, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadHtml(htmlUrl : String){
        // 加载本地Html页面
        guard let url = URL(string: htmlUrl) else {
            print("load html error!!!!!!!")
            return
        }
        let request = URLRequest(url: url)
        //print("load html -----" + htmlUrl)
        webView.load(request)
        // 屏幕旋转通知
        // NotificationCenter.default.addObserver(self, selector: #selector(transitionMethod), name: UIDevice.orientationDidChangeNotification, object: nil)
    }



    
}
