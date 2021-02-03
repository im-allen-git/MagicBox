//
//  StringTools.swift
//  MagicBox
//
//  Created by admin on 2020/8/5.
//  Copyright © 2020年 Kairong. All rights reserved.
//

import Foundation

class StringTools : NSObject {
    
    // 字符串定位
    static func positionOf(str: String , sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = str.range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = str.distance(from:str.startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    // 字符串判断是否为空
    static func isEmpty(str: String)-> Bool{
        if(str == nil){
            return true
        }
        return str == "" || str == "(null)" || 0 == str.count
    }
    
    static func isNotEmpty(str: String)-> Bool{
        return isEmpty(str: str) ? false : true
    }
    
    // 字符串替换
    static func replaceString(str:String, subStr: String, replaceStr: String)->String{
        
        
        
        if(isNotEmpty(str: str) && isNotEmpty(str: subStr)){
            let tempStr = str.trimmingCharacters(in: .whitespaces)
            
            return  tempStr.replacingOccurrences(of: subStr, with: replaceStr)
            

            
//            var index = positionOf(str: tempStr, sub: subStr)
//            while(index > -1){
//                let startIndex = str.index(str.startIndex, offsetBy: index - 1)
//                let endIndex = str.index(str.startIndex, offsetBy: index - 1 + subStr.count)
//                let  range = startIndex...endIndex
//
//  
//
//                // tempStr = tempStr.replacingCharacters(in: startIndex...endIndex, with: subStr)
//                tempStr.replaceSubrange(range, with: replaceStr)
//                index = positionOf(str: tempStr, sub: subStr)
//            }
//            return tempStr.trimmingCharacters(in: .whitespaces)
        }
        return str
        
    }
    
    
    //数组转json
    static func getJSONStringFromArray(array:NSArray) -> String {
        
        if (!JSONSerialization.isValidJSONObject(array)) {
            print("无法解析出JSONString")
            return ""
        }
        
        let data : NSData! = try? JSONSerialization.data(withJSONObject: array, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
        
    }
    
    
    // 字典或者数组 转 JSON
    static func dataTypeTurnJson(element:AnyObject) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: element, options: JSONSerialization.WritingOptions.prettyPrinted)
        let str = String(data: jsonData, encoding: String.Encoding.utf8)!
        return str
    }
    
    
    //数组转json
    func getJSONStringFromArray(array:NSArray) -> String {
         
        if (!JSONSerialization.isValidJSONObject(array)) {
            print("无法解析出JSONString")
            return ""
        }
         
        let data : NSData! = try? JSONSerialization.data(withJSONObject: array, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
         
    }
    
    
    static func fromBase64(code : String) -> String{
        
        let decodedData = NSData(base64Encoded: code, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
        
        //        //转换数据
        //        //let imageData = try? Data(contentsOf: NSURL(string: self.tempImgStr)! as URL) //备用方法
        //        let base64String = code.replacingOccurrences(of: "data:image/png;base64,", with: "")
        //        //转换尝试判断，有可能返回的数据丢失"=="，如果丢失，swift校验不通过
        //        var imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
        //        if imageData == nil {
        //            imageData = Data(base64Encoded: base64String + "==", options: .ignoreUnknownCharacters) //如果数据不正确，添加"=="重试
        //        }
        //
        //        if(imageData == nil){
        //            return ""
        //        } else{
        //            return NSString(data:imageData! ,encoding: String.Encoding.utf8.rawValue)! as String
        //            // return String(data: imageData ?? "", encoding: String.Encoding.utf8)!
        //        }
    }
    
    
    
    static func dealJsonString(str: String)-> String{
        if(isNotEmpty(str: str)){
            var tempStr = str;
            //print(tempStr)
            
            tempStr = StringTools.replaceString(str: tempStr, subStr: "\\\\\\", replaceStr: "")
            //print("--------------")
            //print(tempStr)
            
            tempStr = StringTools.replaceString(str: tempStr, subStr: "\"{", replaceStr: "{")
            //print("--------------")
            //print(tempStr)
            
            tempStr = StringTools.replaceString(str: tempStr, subStr: "}\"", replaceStr: "}")
            //print("--------------")
            //print(tempStr)
            tempStr = StringTools.replaceString(str: tempStr, subStr: "\\", replaceStr: "")
            return tempStr
        }
        return str
    }
    
    
    // MARK: 字符串转字典
    static func stringValueDic(_ str: String) -> [String : Any]?{
        let data = str.data(using: String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!,
                        options: .mutableContainers) as? [String : Any] {
            return dict
        }
        return nil
    }
    
}

