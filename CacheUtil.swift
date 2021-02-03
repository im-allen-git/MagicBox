//
//  CacheUtil.swift
//  MagicBox
//
//  Created by xin ning on 2020-11-17.
//  Copyright © 2020 Kairong. All rights reserved.
//

import Foundation
import Alamofire


class  CacheUtil : NSObject{
    
    // sd卡带有的数据
    static var sdGcodeMap: [String: StlGcode] = [:]
    
    
    static func getSDList(flag: Int){
        if(flag > 0){
            getSDInfoByOkHttp()
        } else if(sdGcodeMap.count == 0){
            getSDInfoByOkHttp()
        }
    }
    
    // okhttp 获取sd卡的数据
    static func getSDInfoByOkHttp(){
        if(StringTools.isNotEmpty(str: PrinterConfig.ESP_8266_URL)){
            var rs: String  = "";
            let tempUrl = PrinterConfig.getSDListUrl()
            Alamofire.request(tempUrl).validate().responseData{(DDataRequest) in
                if DDataRequest.result.isSuccess {
                    rs = String.init(data: DDataRequest.data!, encoding: String.Encoding.utf8)!
                    print("getUrl-:" + tempUrl + "--" + rs)
                    genSdListByString(rsStr: rs)
                }
                if DDataRequest.result.isFailure {
                    print("getUrl :" + tempUrl + "--失败！！！")
                }
            }
        }
    }
    
    
    // 根据获取的字符串获取sd卡list数据，做成map集合
    static func genSdListByString(rsStr: String){
        if(StringTools.isNotEmpty(str: rsStr)){
            sdGcodeMap.removeAll()
            
            let rsList: [ Substring] =  rsStr.split(separator: "\n")
            for (_, item) in rsList.enumerated() {
                if(String(item).contains("file list")){
                    continue
                }
                //print("item:" + item)
                let childList: [Substring] = String(item).split(separator: " ")
                //print("childList:")
                //print(childList.description)
                
                if(childList.count >= 2){
                    let stlGcode: StlGcode = StlGcode()
                    stlGcode.localGcodeName = String(childList[0])
                    let files: UInt64 = UInt64(String(childList[1]).trimmingCharacters(in: .whitespaces))!
                    stlGcode.size = StlDealTools.genFileSizByNum(fileSize: files)
                    
                    sdGcodeMap[stlGcode.localGcodeName!] = stlGcode
                }
            }
        }
        
    }
    
    
    
}
