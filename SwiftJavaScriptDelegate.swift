//
//  SwiftJavaScriptDelegate.swift
//  Three3D -- 注册到JSExport后方可使用js调用ios
//
//  Created by admin on 2020/8/3.
//  Copyright © 2020年 Kairong. All rights reserved.
//

import JavaScriptCore
import UIKit
import WebKit

@objc protocol SwiftJavaScriptDelegate: JSExport {
    
    // js调用App的微信支付功能 演示最基本的用法
    func wxPay(orderNo: String)
    
    // js调用App的微信分享功能 演示字典参数的使用
    func wxShare(dict: [String: AnyObject])
    
    // js调用App方法时传递多个参数 并弹出对话框 注意js调用时的函数名
    func showDialog(title: String, message: String)
    
    // js调用App的功能后 App再调用js函数执行回调
    func callHandler(handleFuncName: String)
    
}

@objc class SwiftJavaScriptModel: NSObject, SwiftJavaScriptDelegate {
    
    weak var controller: UIViewController?
    weak var jsContext: JSContext?
    
    func wxPay(orderNo: String) {
        
        print("订单号：", orderNo)
        
        // 调起微信支付逻辑
    }
    
    func wxShare(dict: [String: AnyObject]) {
        
        print("分享信息：", dict)
        
        // 调起微信分享逻辑
    }
    
    func showDialog(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.controller?.present(alert, animated: true, completion: nil)
    }
    
    func callHandler(handleFuncName: String) {
        
        let jsHandlerFunc = self.jsContext?.objectForKeyedSubscript("\(handleFuncName)")
        let dict = ["name": "sean", "age": 18] as [String : Any]
        jsHandlerFunc?.call(withArguments: [dict])
    }
}

