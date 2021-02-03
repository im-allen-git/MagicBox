//
//  AlamofireTools.swift
//  MagicBox
//
//  Created by admin on 2020/8/5.
//  Copyright © 2020年 Kairong. All rights reserved.
//
//  网络工具类

import Foundation
import Alamofire

class AlamofireTools: NSObject {
    
    private static let sessionManager = SessionManager.default
    
    static func uploadFile(dataPath: String, urlString: String)-> String{
        
        authentication()
        
        var rs: String = ""
        Alamofire.upload(URL.init(fileURLWithPath: dataPath), to: urlString).validate().responseData { (DDataRequest) in
            if DDataRequest.result.isSuccess {
                rs = String.init(data: DDataRequest.data!, encoding: String.Encoding.utf8)!
                print("上传结果---------------" + rs)
            }
            if DDataRequest.result.isFailure {
                print("上传失败！！！")
            }
        }
        return rs
        
    }
    
    
    static func downFile(urlString : String, outFileName : String, tempRandomName : String, realFileName : String, stlGcode : StlGcode,  currentGcode: String){
        
        print("urlString:" + urlString)
        
        // 授权
        authentication()
        
        var isSu: Bool = false
        
        //指定下载路径和保存文件名
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("printer3d/" + outFileName)
            
            print("outFileName:")
            print(fileURL)
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        sessionManager.download(urlString, to: destination)
            // Alamofire.download(urlString, to: destination)
            .downloadProgress { progress in
                print("当前进度: \(progress.fractionCompleted)")
            }
            .responseData { response in
                if(response.result.isSuccess){
                    print("下载完毕!")
                    isSu = true
                }
                if(isSu){
                    isSu = FileTools.fileIsExists(path: FileTools.printer3dPath + "/" + outFileName)
                }
                if(isSu){
                    let downGcodeFileName = FileTools.printer3dPath + "/" + outFileName
                    print("downGcodeFileName:" + downGcodeFileName)
                    // 解压gcode文件
                    stlGcode.serverZipGcodeName = downGcodeFileName
                    
                    
                    let tempLocal:Int = StringTools.positionOf(str: currentGcode, sub: "/ios/", backwards: true)
                    var tempUrlStl = String(currentGcode.suffix(currentGcode.count - tempLocal))
                    tempUrlStl = StringTools.replaceString(str: tempUrlStl, subStr: ".gcode.zip", replaceStr: ".stl")
                    stlGcode.urlStl = ServerConfig.SERVER_URL_PRE + tempUrlStl
                    print(stlGcode.urlStl as Any)
                    
                    
                    FileTools.unzipFile(zipPath: downGcodeFileName, destPath: FileTools.printer3dPath)
                    let gcodePath = FileTools.printer3dPath + "/" + tempRandomName + ".gcode"
                    print("gcodePath:" + gcodePath)
                    if(FileTools.fileIsExists(path: gcodePath)){
                        
                        stlGcode.localGcodeName = gcodePath
                        
                        StlDealTools.saveStlInfo(realFilePath: realFileName, stlGcode: stlGcode)
                        // 解析gcode代码，设置文件的大小，耗材等数据
                        
                        StlDealTools.getGcodeInfo(stlGcode: stlGcode)
                    }else{
                        print("解压gcode文件异常")
                    }
                } else{
                    print("下载gcode文件异常")
                }
        }
        
        // Alamofire 4
        //        Alamofire.request(urlString).response { response in // method defaults to `.get`
        //            debugPrint(response)
        //        }
        //
        //        let parameters: Parameters = ["foo": "bar"]
        //
        //        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default)
        //            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
        //                print("Progress: \(progress.fractionCompleted)")
        //            }
        //            .validate { request, response, data in
        //                // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
        //                return .success
        //            }
        //            .responseJSON { response in
        //                debugPrint(response)
        //        }
        //
        //        // Alamofire 4
        //        let destination = DownloadRequest.suggestedDownloadDestination()
        //
        
        
    }
    
    
    static func getUrl(urlString: String)-> String{
        var rs: String  = "";
        Alamofire.request(urlString).validate().responseData{(DDataRequest) in
            if DDataRequest.result.isSuccess {
                rs = String.init(data: DDataRequest.data!, encoding: String.Encoding.utf8)!
                print("getUrl---------------" + rs)
            }
            if DDataRequest.result.isFailure {
                print("getUrl失败！！！")
            }
        }
        return rs
    }
    
    
    static func authentication() {
        sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
    }
    
    
    // 设置超时时间
    static let sharedSessionManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 6000
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    static let sharedSessionManagerEsp: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 6000
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    
    static func authSsl(){
        
        sharedSessionManager.delegate.sessionDidReceiveChallenge = {
            session,challenge in
            return    (URLSession.AuthChallengeDisposition.useCredential,URLCredential(trust:challenge.protectionSpace.serverTrust!))
        }
        //认证相关设置
        // let manager = SessionManager.default
        //        sharedSessionManager.delegate.sessionDidReceiveChallenge = {
        //            session, challenge in
        //            //认证服务器证书
        //            if challenge.protectionSpace.authenticationMethod
        //                == NSURLAuthenticationMethodServerTrust {
        //                print("服务端证书认证！")
        //                let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
        //                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
        //                let remoteCertificateData
        //                    = CFBridgingRetain(SecCertificateCopyData(certificate))!
        //                let cerPath = Bundle.main.path(forResource: "allenjiang", ofType: "cer")!
        //                let cerUrl = URL(fileURLWithPath:cerPath)
        //                let localCertificateData = try! Data(contentsOf: cerUrl)
        //
        //                if (remoteCertificateData.isEqual(localCertificateData) == true) {
        //                    print("服务端证书认证通过!!!")
        //                    let credential = URLCredential(trust: serverTrust)
        //                    challenge.sender?.use(credential, for: challenge)
        //                    return (URLSession.AuthChallengeDisposition.useCredential,
        //                            URLCredential(trust: challenge.protectionSpace.serverTrust!))
        //
        //                } else {
        //                    print("服务端证书认证失败--------")
        //                    return (.cancelAuthenticationChallenge, nil)
        //                }
        //            }
        //                //认证客户端证书
        //            else if challenge.protectionSpace.authenticationMethod
        //                == NSURLAuthenticationMethodClientCertificate {
        //                print("客户端证书认证！")
        //                //获取客户端证书相关信息
        //                let identityAndTrust:IdentityAndTrust = self.extractIdentity();
        //
        //                let urlCredential:URLCredential = URLCredential(
        //                    identity: identityAndTrust.identityRef,
        //                    certificates: identityAndTrust.certArray as? [AnyObject],
        //                    persistence: URLCredential.Persistence.forSession);
        //
        //                return (.useCredential, urlCredential);
        //            }
        //                // 其它情况（不接受认证）
        //            else {
        //                print("其它情况（不接受认证）")
        //                return (.cancelAuthenticationChallenge, nil)
        //            }
        //
        //        }
    }
    
    
    //获取客户端证书相关信息
    static func extractIdentity() -> IdentityAndTrust {
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
        let path: String = Bundle.main.path(forResource: "mykey", ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : "147258369"] //客户端证书密码
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        
        var items : CFArray?
        
        securityError = SecPKCS12Import(PKCS12Data, options, &items)
        
        if securityError == errSecSuccess {
            let certItems:CFArray = items as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!
                //print("\(identityPointer)  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"]
                let trustRef:SecTrust = trustPointer as! SecTrust
                //print("\(trustPointer)  :::: \(trustRef)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"]
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
                                                    trust: trustRef, certArray:  chainPointer!)
            }
        }
        return identityAndTrust;
    }
    
}

//定义一个结构体，存储认证相关信息
struct IdentityAndTrust {
    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:AnyObject
}
