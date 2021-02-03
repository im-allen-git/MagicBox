//
//  File.swift
//  MagicBox
//
//  Created by admin on 2020/8/5.
//  Copyright © 2020年 Kairong. All rights reserved.
//

import Foundation
import MobileCoreServices

class FileTools: NSObject {
    static let fileManager = FileManager.default
    
    //Documents目录
    static let documentPath = NSHomeDirectory() + "/Documents"
    //Library目录
    static let libraryPath = NSHomeDirectory() + "/Library"
    //Cache目录
    static let cachePath = NSHomeDirectory() + "/Library/Caches"
    
    // 用于存放临时文件，保存应用程序再次启动过程中不需要的信息，重启后清空
    static let tmpDir = NSTemporaryDirectory()
    static let tmpDir2 = NSHomeDirectory() + "/tmp"
    // 3d文件存放位置
    static let printer3dPath = documentPath + "/printer3d"
    
    static let PLIST_NAME_PATH = documentPath + "/printer3d.data"
    
    static let APP_TEMP_PATH = tmpDir2 + "/printer3d"
    
    // plist的字典
    static var plistData: NSMutableDictionary?
    
    // 保存stlGcode的list数据的plist
    static let stlGcodeListPath = documentPath + "/stlGcodeList.data";
    
    //stlGcodeList data
    static var stlListData: NSMutableDictionary?
    
    /**
     进行文件保存
     */
    
    static func saveFile(fileName: String, receivedString: String)-> Bool{
        
        if(StringTools.isEmpty(str: receivedString)){
            return false
        }
        
        let _isParentPath = createDir(dirPath: printer3dPath)
        // let filePath = printer3dPath + "/" + fileName
        
        // 如果是创建的目录，则不需要判断文件是否存在
        if(_isParentPath){
            let _exist = fileManager.fileExists(atPath: fileName);//将 文件地址存到 变量 exist中
            if _exist{
                try! fileManager.removeItem(atPath: fileName)
            }
        }
        
        let f_exist = fileManager.createFile(atPath: fileName, contents: nil, attributes:nil)
        print(fileName + "文件创建结果: \(f_exist)")
        if(f_exist){
            let handle = FileHandle(forWritingAtPath: fileName)
            handle?.write(receivedString.data(using: String.Encoding.utf8)!)
        }
        
        
        //        f_exist = fileManager.fileExists(atPath: fileName);
        //        let data2 = fileManager.contents(atPath: fileName)
        //        let readString2 = String(data: data2!, encoding: String.Encoding.utf8)
        //        print("文件内容: \(String(describing: readString2))")
        
        
        return f_exist
    }
    
    // 创建文件目录
    static func createDir(dirPath: String)-> Bool{
        // print(APP_TEMP_PATH)
        var _isParentPath =  directoryIsExists(path: dirPath)
        if(!_isParentPath){
            try! fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            _isParentPath = true
        }
        return _isParentPath
    }
    
    
    /**
     文件删除
     */
    static func deleteFile(fileName: String){
        let _exist = fileManager.fileExists(atPath: fileName);//将 文件地址存到 变量 exist中
        if(_exist){
            try! fileManager.removeItem(atPath: fileName);
        }
        
    }
    
    /**
     解压文件
     */
    static func unzipFile(zipPath: String, destPath: String){
        SSZipArchive.unzipFile(atPath: zipPath, toDestination: destPath)
    }
    
    
    /**
     压缩文件
     */
    static func zipFile(sourceFileName: String,destZipName: String)-> Bool{
        
        print("zipFile:")
        
        print(sourceFileName)
        print(destZipName)
        
        //        let prePath = sourceFileName.prefix(StringTools.positionOf(str: sourceFileName, sub: "."))
        //        print(prePath)
        //        let jsonPath = Bundle.main.path(forResource: String(prePath), ofType: "stl")
        
        let files = [sourceFileName]
        SSZipArchive.createZipFile(atPath: destZipName, withFilesAtPaths : files)
        
        
        //        do{
        // 先拷贝到临时目录中
        //            let tempDir = tempDestPath()
        //            // 倒序获取定位数据
        //            let suffixNum = StringTools.positionOf(str:sourceFileName,sub:"/", backwards:true)
        //            // 尾部截取
        //            let endSuffix: String = String(sourceFileName.suffix(sourceFileName.count - suffixNum))
        //            let tempAllPath =  tempDir! + "/" + endSuffix
        //            try fileManager.copyItem(at: NSURL(fileURLWithPath: sourceFileName) as URL, to: NSURL(fileURLWithPath:tempAllPath) as URL)
        //            // 进行ZIP压缩
        //            SSZipArchive.createZipFile(atPath: destZipName, withContentsOfDirectory: tempDir!)
        //            // print(tempDir!)
        //            // 删除临时文件
        //            try fileManager.removeItem(at: NSURL(fileURLWithPath: tempDir!) as URL)
        //        }catch{
        //            print(error)
        //        }
        return fileManager.fileExists(atPath: destZipName)
    }
    
    
    //在Caches文件夹下随机创建一个文件夹，并返回路径
    static func tempDestPath() -> String? {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                       .userDomainMask, true)[0]
        path += "/\(NSUUID().uuidString)"
        let url = NSURL(fileURLWithPath: path)
        
        do {
            try fileManager.createDirectory(at: url as URL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        
        if let path = url.path {
            print("path:\(path)")
            return path
        }
        return nil
    }
    
    
    /**
     判断是否是文件夹的方法
     */
    static func directoryIsExists(path: String) -> Bool {
        var directoryExists = ObjCBool.init(false)
        let fileExists = fileManager.fileExists(atPath: path, isDirectory: &directoryExists)
        return fileExists && directoryExists.boolValue
    }
    
    static func fileIsExists(path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }
    
    /**
     获取文件全路径
     */
    static func getFileAllPath(fileName: String)-> String{
        return printer3dPath + "/" + fileName;
    }
    
    
    static func getRandomFilePath()-> String{
        // 随机数
        let randomNum = Int.random(in: 1000...9999)
        // 时间戳
        let date = Date(timeIntervalSinceNow: 0)
        let a = date.timeIntervalSince1970
        let timeStamp = String.init(format: "%.f", a)
        
        return timeStamp + "_" +  String(randomNum);
    }
    
    
    //根据后缀获取对应的Mime-Type
    static func mimeType(pathExtension: String) -> String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                           pathExtension as NSString,
                                                           nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
                .takeRetainedValue() {
                return mimetype as String
            }
        }
        //文件资源类型如果不知道，传万能类型application/octet-stream，服务器会自动解析文件类
        return "application/octet-stream"
    }
    
    
    /**
     创建 printer3d的plist，用于存储使用信息，如打印机Wi-Fi，启动页加载等
     */
    static func saveToPlist(keyName: String, val : String)-> Bool{
        
        // try? fileManager.removeItem(atPath: PLIST_NAME_PATH)
        
        if !fileIsExists(path: PLIST_NAME_PATH){
            fileManager.createFile(atPath: PLIST_NAME_PATH, contents: nil, attributes: nil) // create the file
            // fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        if !fileIsExists(path: PLIST_NAME_PATH){
            print("create plist error")
            return false
        } else{
            print(PLIST_NAME_PATH + ",fileIsExists")
        }
        
        let data : NSMutableDictionary = NSMutableDictionary.init(contentsOfFile: PLIST_NAME_PATH) ?? NSMutableDictionary()
        
        data.setObject(val, forKey: keyName as NSCopying)
        let bl = data.write(toFile: PLIST_NAME_PATH, atomically: true)
        
        
        let resultDict = NSMutableDictionary(contentsOfFile: PLIST_NAME_PATH)
        print("result, dict: \(String(describing: resultDict))")
        
        return bl
    }
    
    /**
     获取plist里面的数据
     */
    static func getByPlist(keyName: String)-> String{
        if(fileIsExists(path: PLIST_NAME_PATH)){
            //            plistData = NSMutableDictionary.init(contentsOfFile: PLIST_NAME_PATH)!  //获取文件的路径，获取文件的类型，我的例子是字典型（有字典型和数组型可选）
            //            return plistData[keyName]! as! String   //利用键-值对的方式，进行存取
            
            plistData = NSMutableDictionary(contentsOfFile: PLIST_NAME_PATH)
            print("plistData")
            print(plistData as Any)
            
            let rsStr = plistData?.object(forKey: keyName)
            return rsStr == nil ? "" : rsStr as! String
        }
        return ""
    }
    
    
    // 复制一个文件，到目标位置
    static func copyFile(sourceUrl:String, targetUrl:String) -> Bool{
        var isSu: Bool = false
        do{
            try fileManager.copyItem(atPath: sourceUrl, toPath: targetUrl)
            print("Success to copy file.")
            isSu = true
        }catch{
            print("sourceUrl:")
            print(sourceUrl)
            print("targetUrl:")
            print(targetUrl)
            print("Failed to copy file.")
        }
        return isSu
    }
    
    // 新增stlGcodeList的plist 数据
    class func saveStlGcodeList(stlGcode: StlGcode)-> Bool{
        //print("stlGcodeListPath:" + stlGcodeListPath)
        if !fileIsExists(path: stlGcodeListPath){
            fileManager.createFile(atPath: stlGcodeListPath, contents: nil, attributes: nil) // create the file
            // fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        if !fileIsExists(path: stlGcodeListPath){
            print("create plist error")
            return false
        } else{
            print(stlGcodeListPath + ",file is exists")
        }
        
        let data : NSMutableDictionary = NSMutableDictionary.init(contentsOfFile: stlGcodeListPath) ?? NSMutableDictionary()
        data.setObject(stlGcode.getJsonString(), forKey: stlGcode.realStlName! as NSCopying)
        let bl = data.write(toFile: stlGcodeListPath, atomically: true)
        
        //let resultDict = NSMutableDictionary(contentsOfFile: stlGcodeListPath)
        //print("stlGcodeListPath, dict: \(String(describing: resultDict))")
        print("save " + stlGcodeListPath + ",rs:" + String(bl))
        return bl
    }
    
    
    
    // 获取stlGcodeList 的plist数据
    static func getFromstlGcodeList(){
        if(fileIsExists(path: stlGcodeListPath)){
            //print("stlGcodeListPath:" + stlGcodeListPath)
            StlDealTools.stlMap.removeAll()
            stlListData = NSMutableDictionary.init(contentsOfFile: stlGcodeListPath) ?? NSMutableDictionary()
            //print("old dataDict")
            
            //print(stlListData as Any)
            for (_, item) in stlListData!.enumerated() {
                //print("item key:")
                //print(item.key as! String)
                //print("item val:")
                let rsJson = StringTools.stringValueDic(item.value as! String)
                let tempStl = StlGcode()
                tempStl.id = Int(rsJson!["id"] as! String)!
                tempStl.sourceStlName = rsJson!["sourceStlName"] as? String
                tempStl.realStlName = rsJson!["realStlName"] as? String
                tempStl.sourceZipStlName = rsJson!["sourceZipStlName"] as? String
                tempStl.serverZipGcodeName = rsJson!["serverZipGcodeName"] as? String
                tempStl.localGcodeName = rsJson!["localGcodeName"] as? String
                tempStl.createTime = rsJson!["createTime"] as? String
                tempStl.localImg = rsJson!["localImg"] as? String
                tempStl.length = rsJson!["length"] as? String
                tempStl.width = rsJson!["width"] as? String
                tempStl.height = rsJson!["height"] as? String
                tempStl.size = rsJson!["size"] as? String
                tempStl.material = rsJson!["material"] as? String
                tempStl.exeTime = Int32(rsJson!["exeTime"] as! String)!
                tempStl.flag = Int(rsJson!["flag"] as! String)!
                tempStl.localFlag = Int(rsJson!["localFlag"] as! String)!
                tempStl.urlStl = rsJson!["urlStl"] as? String
                tempStl.urlImg = rsJson!["urlImg"] as? String
                print(tempStl.getJsonString())
                StlDealTools.setStlMap(key: item.key as! String, stlGcode: tempStl)
            }
        }
    }
    
    static func removePlistByKey(stlUrl : String )-> Bool{
        stlListData = NSMutableDictionary.init(contentsOfFile: stlGcodeListPath) ?? NSMutableDictionary()
        var count:Int = 0
        for (_, item) in stlListData!.enumerated() {
            if((item.key as! String) == stlUrl){
                stlListData?.removeObject(forKey: stlUrl)
                count = count + 1
                break
            }
        }
        if(count > 0){
            let bl =  stlListData?.write(toFile: stlGcodeListPath, atomically: true)
            return bl!
        }else{
            return false
        }
    }
    
    
}
