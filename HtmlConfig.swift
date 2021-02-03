//
//  HtmlConfig.swift
//  MagicBox
//
//  Created by admin on 2020/8/6.
//  Copyright © 2020年 Kairong. All rights reserved.
//

import Foundation
class HtmlConfig  : NSObject {
    
    static let bundlePath = Bundle.main.bundlePath
    
    static let FILE_BUNDEL_PATH = "file://\(bundlePath)/assets/"

    static let  SERVER_SHOP_HTML: String =  ServerConfig.SERVER_URL_PRE +  "/shopping.html"
    static let  BULID_MODULE_URL: String = ServerConfig.SERVER_URL_PRE + "/3DPrinting.html"
    static let  CUSTOMIZE_HTML: String = ServerConfig.SERVER_URL_PRE + "/customizedModel.html"

//    static let  BULID_MODULE_URL: String = FILE_BUNDEL_PATH + "src/3DPrinting.html"
    static let  MYMODULE_HTML: String = FILE_BUNDEL_PATH + "src/my_module.html"

    static let  SHOP_HTML: String = FILE_BUNDEL_PATH + "src/shopping.html"
    static let  INDEX_HTML: String = FILE_BUNDEL_PATH + "src/index.html"
    static let  WELCOME_SLIDE_HTML: String = FILE_BUNDEL_PATH + "src/welcome_slide.html"
    static let  UPLOAD_GCODE_HTML: String = FILE_BUNDEL_PATH + "src/upload_gcode.html"
    static let  WIFI_PASS_HTML: String = FILE_BUNDEL_PATH + "src/wifi_connect.html"
    static let  UPLOAD_DEMO_HTML: String = FILE_BUNDEL_PATH + "src/upload_demo.html"
    static let  PRINTER_INTRO_HTML: String = FILE_BUNDEL_PATH + "src/printer_intro.html"
    static let  PRINTER_INTRO_FIRST_HTML: String = FILE_BUNDEL_PATH + "src/printer_intro_first.html"
    static let  PRINTER_STATUS_HTML: String = FILE_BUNDEL_PATH + "src/printer_status.html"
    
    static let  FIRST_WELCOME: String = FILE_BUNDEL_PATH + "src/welcome.html"
    static let  WELCOME_SLIDE: String = FILE_BUNDEL_PATH + "src/welcome_slide.html"

    
    
    
    
    static var uuid = ""
    
    // 加载本地Html页面
    static func getUrlRequest(htmlUrl: String)-> URLRequest{
        guard let url = URL(string: HtmlConfig.INDEX_HTML) else {
            print("load html error!!!!!!!")
            return URLRequest(url: URL(string: "")!)
        }
        return URLRequest(url: url)
    }
    
    
    
}
