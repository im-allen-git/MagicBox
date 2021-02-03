//
//  PrinterConfig.swift
//  MagicBox
//
//  Created by xin ning on 2020-09-02.
//  Copyright © 2020 Kairong. All rights reserved.
//

class PrinterConfig : NSObject{
    
    static let HOUR_TIME:Int32 = Int32(60 * 60 * 1000)
    
    static let MINUTE_TIME:Int32 = Int32(60 * 1000)
    
    static let SECOND_TIME:Int32 = Int32(1000)
    
    
    static var ESP_8266_URL: String = "";
    
    static var LOCAL_GCODE: String = "";
    
    static var GEN_GCODE: String  = "";
    
    static var STL_GCODE: StlGcode? = nil;
    
    
    static func getSDListUrl()-> String{
        return PrinterConfig.ESP_8266_URL + "/command?commandText=M20&PAGEID=0"
    }
    
    
    
    static func getPostFileUrl()-> String{
        
        return PrinterConfig.ESP_8266_URL + "/upload_serial"
    }
    
    
    static func getPrinterCommond(gcodeName: String) -> String{
        var tempNameStr = String(gcodeName.prefix(StringTools.positionOf(str: gcodeName, sub: ".", backwards: true)))
        let lastName = String(gcodeName.suffix(gcodeName.count - StringTools.positionOf(str: gcodeName, sub: ".", backwards: true)))
        if(tempNameStr.count > 8){
            tempNameStr = gcodeName.prefix(5) + "_~1" + lastName
        }else{
            tempNameStr = gcodeName
        }
        return PrinterConfig.ESP_8266_URL + "/command_silent?commandText=M23%20/" + tempNameStr.uppercased() + "%0AM24&PAGEID=0"
    }
    
    static func checkWifi()-> Int{
        var flag: Int = 0;
        if(StringTools.isNotEmpty(str: PrinterConfig.ESP_8266_URL)){
            flag = 1;
        } else{
            let wifiUrl =  FileTools.getByPlist(keyName: ServerConfig.WiFi_URL_KEY)
            flag = StringTools.isEmpty(str: wifiUrl) ? 0 : 1
            if(flag > 0){
                PrinterConfig.ESP_8266_URL = wifiUrl
            }
        }
        return flag
    }
    
    
    static func setWifiInfo(){
        if(StringTools.isEmpty(str: PrinterConfig.ESP_8266_URL)){
            let wifiUrl =  FileTools.getByPlist(keyName: ServerConfig.WiFi_URL_KEY)
            if(StringTools.isNotEmpty(str: wifiUrl) ){
                PrinterConfig.ESP_8266_URL = wifiUrl
            }
        }
    }
    
}
