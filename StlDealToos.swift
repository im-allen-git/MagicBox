//
//  StlGcodeToos.swift
//  MagicBox
//
//  Created by admin on 2020/8/5.
//  Copyright © 2020年 Kairong. All rights reserved.
//

import Foundation
import WebKit

class StlDealTools: NSObject {
    
    static var webView: WKWebView?
    
    static var code: String?
    
    /**
     创建后stl读取模型列表
     */
    static var stlGcodeList:[String] = [String]()
    
    /**
     * 原始保存的stl数据
     */
    public static var stlMap: [String: StlGcode] = [:]
    
    /**
     * APP自带gcode的map
     */
    static var localMapStl: [String: StlGcode]  = [:]
    
    /**
     * APP自带gcode集合
     */
    static var localStlList:[String] = [String]()
    
    /**
     * 从数据库读取和后续更新的数据
     */
    static var stlDataBaseMap: [String: StlGcode]  = [:]
    
    static var data_list = [[String: String]]()
    
    static let b_size: UInt64 = 1024
    static let k_size: UInt64 = b_size * 1024
    static let m_size: UInt64 = k_size * 1024
    static let g_size: UInt64 = m_size * 1024
    /**
     保存stl对象到字典中
     */
    static func saveStlInfo(realFilePath :String, stlGcode: StlGcode){
        //print(realFilePath)
        //print(stlGcode.getJsonString())
        stlMap[realFilePath] = stlGcode
        // 保存到plist中
        var isSu = FileTools.saveStlGcodeList(stlGcode: stlGcode)
        if(!isSu){
            isSu = FileTools.saveStlGcodeList(stlGcode: stlGcode)
        }
        
        let tempStr = StlDealTools.getStlList()
        
        if(code == "4"){
            webView!.evaluateJavaScript("loadLocalAppStl('" + tempStr + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
        } else {
            webView!.evaluateJavaScript("thisParamInfo(2,'" + tempStr + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
        }
        
        
    }
    
    static func setStlMap(key: String , stlGcode: StlGcode){
        stlMap[key] = stlGcode
    }
    
    
    /**
     字典里面判断是否存在的key值
     */
    static func checkIsExistsFile(fileName: String)-> Bool{
        return stlMap.keys.contains(fileName)
    }
    
    static func getNowTheTime() -> String {
        // create a date formatter
        let dateFormatter = DateFormatter()
        // setup formate string for the date formatter
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // format the current date and time by the date formatter
        let dateStr = dateFormatter.string(from: Date())
        return dateStr
    }
    
    // 获取stl保存的数据
    static func getStlList()-> String{
        stlGcodeList.removeAll()
        for (_,val) in stlMap{
            copyToTempFile(stlGcode: val)
            stlGcodeList.append(val.getJsonString())
            //let rsJson = val.getJsonString()
            //stlGcodeList.append(StringTools.replaceString(str: rsJson, subStr: "/Documents/", replaceStr: "/tmp/"))
        }
//        let jsonData = try! JSONSerialization.data(withJSONObject: stlGcodeList, options: JSONSerialization.WritingOptions.prettyPrinted)
//        return String(data: jsonData, encoding: String.Encoding.utf8)!
//
        
        return StringTools.dealJsonString(str: StringTools.getJSONStringFromArray(array: stlGcodeList as NSArray));
    }
    
    static func copyToTempFile(stlGcode : StlGcode){
        let destImg = StringTools.replaceString(str: stlGcode.localImg!, subStr: "/Documents/", replaceStr: "/tmp/")
        if(!FileTools.fileIsExists(path: destImg)){
            // 文件copy到 APP_TEMP_PATH
            // let prePath = destImg.prefix(StringTools.positionOf(str: destImg, sub: "/", backwards: true))
            // print(prePath)
            // print(destImg)
            // var isSu: Bool = FileTools.createDir(dirPath: String(prePath))
//            if(isSu){
//                var isSu = FileTools.copyFile(sourceUrl: stlGcode.localImg!, targetUrl: destImg)
//            }
            FileTools.copyFile(sourceUrl: stlGcode.localImg!, targetUrl: destImg)
//            if(!isSu){
//                print(stlGcode.localImg! + ", copy error!!!!")
//                print(destImg + ", copy error!!!!")
//            }
        }
    }
    
    
    /**
     本地文件list列表
     */
    static func getLocalStl() -> String{
        let stlPathPre = HtmlConfig.FILE_BUNDEL_PATH + "models/stl/localModules/"
        if(localStlList.isEmpty){
            localStlList = [String]()
            let  kitty: StlGcode = StlGcode(id:1, sourceStlName:"hello_kitty.stl",realStlName:stlPathPre + "hello_kitty.stl",sourceZipStlName:"",serverZipGcodeName:"",localGcodeName:stlPathPre + "hello_kitty.gco",createTime:"",
                                            localImg:stlPathPre + "hello_kitty.png",length:"X:74.01",width:"Y:51.22",height:"Z:100.93",size:"18.20M",material:"7318cm",exeTime:(1025*60),exeTimeStr:self.getTimeStr(count: (200 + (1025*60)) * PrinterConfig.SECOND_TIME),flag:1,localFlag:1, urlStl: "", urlImg: "")
            localStlList.append(kitty.getJsonString())
            localMapStl[kitty.getShortLocalGcodeName()] = kitty
            
            
            let  chamaeleo_t: StlGcode = StlGcode(id:2, sourceStlName:"chamaeleo_t.stl",realStlName:stlPathPre + "chamaeleo_t.stl",sourceZipStlName:"",serverZipGcodeName:"",localGcodeName:stlPathPre + "chamaeleo_t.gco",createTime:"",
                                                  localImg:stlPathPre + "chamaeleo_t.png",length:"X:92.89",width:"Y:93.08",height:"Z:25.98",size:"5.33M",material:"780cm",exeTime:(110*60),exeTimeStr: self.getTimeStr(count: (200 + (110*60)) * PrinterConfig.SECOND_TIME),flag:1,localFlag:1, urlStl: "", urlImg: "")
            localStlList.append(chamaeleo_t.getJsonString())
            localMapStl[chamaeleo_t.getShortLocalGcodeName()] = chamaeleo_t
            
            
            let  hand_ok: StlGcode = StlGcode(id:3, sourceStlName:"hand_ok.stl",realStlName:stlPathPre + "hand_ok.stl",sourceZipStlName:"",serverZipGcodeName:"",localGcodeName:stlPathPre + "hand_ok.gco",createTime:"",
                                              localImg:stlPathPre + "hand_ok.png",length:"X:42.78",width:"Y:57.72",height:"Z:110.44",size:"16.40M",material:"2168cm",exeTime:(304*60),exeTimeStr: self.getTimeStr(count: (200 + (304*60)) * PrinterConfig.SECOND_TIME),flag:1,localFlag:1, urlStl: "", urlImg: "")
            localStlList.append(hand_ok.getJsonString())
            localMapStl[hand_ok.getShortLocalGcodeName()] = hand_ok
            
            
            let  jet_pack_bunny: StlGcode = StlGcode(id:4, sourceStlName:"jet_pack_bunny.stl",realStlName:stlPathPre + "jet_pack_bunny.stl",sourceZipStlName:"",serverZipGcodeName:"",localGcodeName:stlPathPre + "jet_pack_bunny.gco",createTime:"",
                                                     localImg:stlPathPre + "jet_pack_bunny.png",length:"X:130.43",width:"Y:92.01",height:"Z:131.28",size:"48.20M",material:"2168cm",exeTime:(304*60),exeTimeStr: self.getTimeStr(count: (200 + (304*60)) * PrinterConfig.SECOND_TIME),flag:1,localFlag:1, urlStl: "", urlImg: "")
            localStlList.append(jet_pack_bunny.getJsonString())
            localMapStl[jet_pack_bunny.getShortLocalGcodeName()] = jet_pack_bunny
            
            let  god_of_wealth: StlGcode = StlGcode(id:5, sourceStlName:"god_of_wealth.stl",realStlName:stlPathPre + "god_of_wealth.stl",sourceZipStlName:"",serverZipGcodeName:"",localGcodeName:stlPathPre + "god_of_wealth.gco",createTime:"",
                                                    localImg:stlPathPre + "god_of_wealth.png",length:"X:62.85",width:"Y:57.72",height:"Z:64.23",size:"23.40M",material:"1945cm",exeTime:(273*60),exeTimeStr: self.getTimeStr(count: (200 + (273*60)) * PrinterConfig.SECOND_TIME),flag:1,localFlag:1, urlStl: "", urlImg: "")
            localStlList.append(god_of_wealth.getJsonString())
            localMapStl[god_of_wealth.getShortLocalGcodeName()] = god_of_wealth
        }
        // return NSMutableArray(array : localStlList)
        // return localStlList;
        
        
        return StringTools.dealJsonString(str: StringTools.getJSONStringFromArray(array: localStlList as NSArray))
    }
    
    
    static func getGcodeInfo(stlGcode : StlGcode){
        let isExists = FileManager.default.fileExists(atPath: stlGcode.localGcodeName!)
        if(isExists){
            
            genFileSize(stlGcode: stlGcode);
            
            let gcodeInfo = try? NSString(contentsOfFile: stlGcode.localGcodeName!, encoding: String.Encoding.utf8.rawValue)
            
            // 根据换行符号获取数组信息
            var infoArr : Array = gcodeInfo!.components(separatedBy: "\r\n")
            
            // 定义长宽高等数据，用于计算
            var gcodeMap:[String:Double] = ["X_N": 0, "Y_N": 0,"Z_N": 0, "X_M": 0,"Y_M": 0, "Z_M": 0,"size": 0, "fill_density":0,"perimeter_speed": 0,"filament_used": 0]
            
            // for i in 0..<infoArr.count{
            // print(String(i) + ": " + infoArr[i])
            // paraseGcodeLine(gcodeMap:gcodeMap,infoLine: infoArr[i])
            //            }
            
            for infoLine in infoArr{
                // print(String(i) + ": " + infoArr[i])
                // paraseGcodeLine(gcodeMap:gcodeMap,infoLine: infoLine)
                
                let infoLineTrim = infoLine.trimmingCharacters(in: .whitespaces)
                
                if(infoLineTrim.starts(with: "G1")){
                    let tempList: Array = infoLine.components(separatedBy: " ")
                    for child in tempList{
                        var tempD: Double = 0
                        if(child.starts(with: "X")){
                            tempD = Double(child.suffix(child.count-1))!
                            if(gcodeMap["X_M"]! < tempD){
                                gcodeMap["X_M"] = tempD
                            }
                            if(gcodeMap["X_N"]! == 0 || gcodeMap["X_N"]! > tempD){
                                gcodeMap["X_N"] = tempD
                            }
                        } else if(child.starts(with: "Y")){
                            tempD = Double(child.suffix(child.count-1))!
                            if(gcodeMap["Y_M"]! < tempD){
                                gcodeMap["Y_M"] = tempD
                            }
                            if(gcodeMap["Y_N"]! == 0 || gcodeMap["Y_N"]! > tempD){
                                gcodeMap["Y_N"] = tempD
                            }
                        } else if(child.starts(with: "Z")){
                            tempD = Double(child.suffix(child.count-1))!
                            if(gcodeMap["Z_M"]! < tempD){
                                gcodeMap["Z_M"] = tempD
                            }
                            if(gcodeMap["Z_N"]! == 0 || gcodeMap["Z_N"]! > tempD){
                                gcodeMap["Z_N"] = tempD
                            }
                        }
                        
                    }
                } else if(infoLineTrim.starts(with: "; fill_density")){
                    // 填充率
                    //let tempList = infoLineTrim.suffix(StringTools.positionOf(str: infoLineTrim, sub: "=") + 1)
                    let tempList = infoLineTrim.components(separatedBy: "=")[1].trimmingCharacters(in: .whitespaces);
                    if(tempList.contains("%")){
                        let reStr = StringTools.replaceString(str: String(tempList), subStr: "%", replaceStr: "")
                        gcodeMap["fill_density"] = Double(reStr)! / Double(100)
                    } else{
                        gcodeMap["fill_density"] = Double(tempList.trimmingCharacters(in: .whitespaces))!
                    }
                    
                } else if(infoLineTrim.starts(with: "; perimeter_speed")){
                    // 打印速度
                    // let tempList = infoLineTrim.suffix(StringTools.positionOf(str: infoLineTrim, sub: "=") + 1)
                    let tempList = infoLineTrim.components(separatedBy: "=")[1].trimmingCharacters(in: .whitespaces)
                    if(tempList.contains("mm")){
                        let reStr = StringTools.replaceString(str: String(tempList), subStr: "mm", replaceStr: "")
                        gcodeMap["perimeter_speed"] = Double(reStr)! / Double(100)
                    } else{
                        gcodeMap["perimeter_speed"] = Double(tempList.trimmingCharacters(in: .whitespaces))!
                    }
                    
                } else if(infoLineTrim.starts(with: "; filament used")){
                    print("filament used:" + infoLineTrim)
                    // 耗材
                    let tempList = infoLineTrim.components(separatedBy: "=")[1].trimmingCharacters(in: .whitespaces)
                    var  tempUsed: Double = 0
                    if(tempList.contains("mm")){
                        // let reStr = StringTools.replaceString(str: String(tempList), subStr: "mm", replaceStr: "")
                        let reStr = tempList.components(separatedBy: "mm")[0].trimmingCharacters(in: .whitespaces)
                        tempUsed = Double(reStr)!
                    } else{
                        tempUsed  = Double(tempList.trimmingCharacters(in: .whitespaces))!
                    }
                    gcodeMap["filament_used"] = gcodeMap["filament_used"]! + tempUsed
                }
            }
            
            infoArr.removeAll()
            
            print(gcodeMap)
            stlGcode.length = String(format: "%.2f", gcodeMap["X_M"]! - gcodeMap["X_N"]!)
            stlGcode.width = String(format: "%.2f", gcodeMap["Y_M"]! - gcodeMap["Y_N"]!)
            stlGcode.height = String(format: "%.2f", gcodeMap["Z_M"]! - gcodeMap["Z_N"]!)
            
            
            let filamentUsed = gcodeMap["filament_used"]!
            let fillDensity  = gcodeMap["fill_density"]!
            let perimeterSpeed  = gcodeMap["perimeter_speed"]!
            
            stlGcode.material = String(format: "%.2f",  filamentUsed / Double(10)) + "cm"
            
            if(fillDensity > 0 && perimeterSpeed > 0){
                // let exeTime = filamentUsed / perimeterSpeed * fillDensity * Double(PrinterConfig.MINUTE_TIME)
                let exeTime = filamentUsed / perimeterSpeed  * Double(PrinterConfig.MINUTE_TIME)
                
                stlGcode.exeTime = Int32(exeTime) + 200 * PrinterConfig.SECOND_TIME
                stlGcode.exeTimeStr = self.getTimeStr(count: stlGcode.exeTime)
            }
            
            // stlGcode保存
            // print(stlGcode)
            
            // 保存到字典中，相当于Java的map
            StlDealTools.saveStlInfo(realFilePath: stlGcode.realStlName!, stlGcode: stlGcode)
            
        }
    }
    
    static func getTimeStr(count: Int32)->String{
        
        var hourTime: Int32 = 0;
        var minuteTime: Int32 = 0;
        var secondTime: Int32 = 0;
        var timeBf: String = String();
        
        hourTime = count / PrinterConfig.HOUR_TIME;
        if (hourTime > 0) {
            if (hourTime < 10) {
                timeBf.append("0" + String(hourTime) + ":")
            } else {
                timeBf.append("" + String(hourTime) + ":")
            }
        } else {
            timeBf.append("00:");
        }
        
        minuteTime = (count - hourTime * PrinterConfig.HOUR_TIME) / PrinterConfig.MINUTE_TIME;
        if (minuteTime > 0) {
            if (minuteTime < 10) {
                timeBf.append("0" + String(minuteTime) + ":");
            } else {
                timeBf.append("" + String(minuteTime) + ":");
            }
        } else {
            timeBf.append("00:");
        }
        
        secondTime = (count - hourTime * PrinterConfig.HOUR_TIME - minuteTime * PrinterConfig.MINUTE_TIME) / PrinterConfig.SECOND_TIME
        if (secondTime > 0) {
            if (secondTime < 10) {
                timeBf.append("0" + String(secondTime))
            } else {
                timeBf.append("" + String(secondTime))
            }
        } else {
            timeBf.append("00")
        }
        return timeBf
    }
    
    // 换算单位
    static func genFileSize(stlGcode: StlGcode){
        var fileSize : UInt64 = 0
        fileSize = self.getSize(filePath: stlGcode.localGcodeName!)
        stlGcode.size = genFileSizByNum(fileSize: fileSize);
    }
    
    static func genFileSizByNum(fileSize: UInt64)-> String{
        var sizeStr = "0B";
        if(fileSize < b_size){
            sizeStr = String(fileSize) + "B";
        } else if(fileSize < k_size){
            sizeStr = String(fileSize / b_size) + "KB";
        } else if(fileSize < m_size){
            sizeStr = String(fileSize / k_size) + "MB";
        } else if(fileSize < g_size){
            sizeStr = String(fileSize / m_size) + "GB";
        }
        return sizeStr
    }
    
    //获取文件大小
    static func getSize(filePath: String)->UInt64 {
        var fileSize : UInt64 = 0
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            print("Error: \(error)")
        }
        return fileSize
    }
    
    
    //删除文件
    static func deleteStl(fileName: String)->Bool{
        let stlGcode: StlGcode = stlMap[fileName]!
        FileTools.deleteFile(fileName: stlGcode.realStlName!)
        FileTools.deleteFile(fileName: stlGcode.localImg!)
        FileTools.deleteFile(fileName: stlGcode.sourceZipStlName!)
        FileTools.deleteFile(fileName: stlGcode.localGcodeName!)
        FileTools.deleteFile(fileName: stlGcode.serverZipGcodeName!)
        stlMap.removeValue(forKey: fileName)
        return FileTools.removePlistByKey(stlUrl: fileName)
    }
    
    
}

