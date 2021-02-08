//
//  ServerConfig.swift
//  MagicBox
//
//  Created by admin on 2020/8/6.
//  Copyright © 2020年 Kairong. All rights reserved.
//

import Foundation
class ServerConfig : NSObject {
    
    static let  SERVER_URL_PRE: String = "https://3d.import-express.com"
    
    // 上传stl生成gcode路径
    static let  FILE_UPLOAD_URL: String = SERVER_URL_PRE + "/file/uploadFileAndGenGcodeIos"
    static let  FILE_DOWN_URL: String = SERVER_URL_PRE + "/file/downloadFileIos?fileName="
    
    static let  CHECK_NET_URL: String = SERVER_URL_PRE + "/connect/checkNet"
    
    
    static let WiFi_URL_KEY: String = "wifi_url"
    // 第一次进去app
    static let FIRST_ACCESS: String = "first_access"
    // 第一次创建模型
    static let FIRST_BUILD: String = "first_build"
    // 第一次创建我的世界
    static let FIRST_MY_WORLD: String = "first_my_world"
    
    // 第一次定制模型
    static let FIRST_CUSTOMIZED: String = "first_customized"
    
    
    
}
