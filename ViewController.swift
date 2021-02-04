import UIKit
import JavaScriptCore
import WebKit
import Alamofire


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, ESPTouchControllerDelegate {
    
    var espController = ESPTouchController()
    func handleConnectionTimeoutAlert(resultCount:Int){
        if(resultCount == 0 ){
            if let ok = self.okAction{
                ok.isEnabled = true
            }
            self.alertController.title = "Connection Timeout"
            self.alertController.message = "no devices found, check if your ESP is in Connection mode!"
        }
    }
    func handleAddedResult(resultCount:Int, bssid: String!, ip:String!){
        if(resultCount >= self.resultExpected ){ //bug on condition, must know why!
            espController.interruptESP();
            if let ok = self.okAction{
                ok.isEnabled = true
            }
        }
        if(resultCount >= 1 ){
            self.resultCount = self.resultCount + 1
            self.alertController.title = "\(self.resultCount) ESP\(self.resultCount > 1 ? "(s)" :" ") connected"
            self.messageResult  += "\(String(describing: bssid)) - ip: \(String(describing: ip))\n";
            self.alertController.message = self.messageResult;
            
            PrinterConfig.ESP_8266_URL = "http://" + ip
            print(PrinterConfig.ESP_8266_URL)
            var isSu = FileTools.saveToPlist(keyName: ServerConfig.WiFi_URL_KEY, val: PrinterConfig.ESP_8266_URL)
            if(!isSu){
                isSu = FileTools.saveToPlist(keyName: ServerConfig.WiFi_URL_KEY, val: PrinterConfig.ESP_8266_URL)
            }
        }
    }
    
    
    
    var resultExpected = 0
    var alertController = UIAlertController()
    var messageResult = ""
    var resultCount = 0
    var okAction:UIAlertAction?
    var bssid: String?
    
    @IBOutlet var numberOfDevicesLabel: UILabel!
    @IBOutlet var passwordInputText: UITextField!
    @IBOutlet var ssidInputText: UITextField!
    @IBOutlet var isHiddenSwitch: UISwitch!
    
    @IBAction func onNumberDevicesChange(_ sender: UISlider) {
        resultExpected = Int(sender.value)
        numberOfDevicesLabel.text = resultExpected == 0 ? "All" : resultExpected.description
    }
    
    @IBAction func onChangeIsHidden(_ sender: Any) {
        if(self.isHiddenSwitch.isOn){
            self.ssidInputText.isUserInteractionEnabled = true;
            self.ssidInputText.borderStyle =  UITextField.BorderStyle.roundedRect;
        }
        else {
            self.ssidInputText.isUserInteractionEnabled = false;
            self.ssidInputText.borderStyle =  UITextField.BorderStyle.none;
        }
    }
    
    
    @IBAction func send(_ sender: UIButton) {
        if  self.ssidInputText.text?.compare("Not Connected to Wifi").rawValue != 0{
            self.espController.delegate = self;
            self.showAlertWithResult(title:"Connetting...",message:"");
            self.espController.sendSmartConfig(bssid: self.bssid!, ssid: self.ssidInputText.text!, password: self.passwordInputText.text!, resultExpected: Int32(self.resultExpected));
        }
    }
    
    
    
    var wifiInfo: Dictionary<String, String> = Dictionary<String, String>()
    
    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    var message = "";
    
    var screenWidth:CGFloat = 0;
    var screenHeight:CGFloat = 0;
    var isFlag = false;
    var codeStl:String = "-1";
    
    var beforeCode: String = "0"
    
    // 网络是否通畅标示
    var netFlag = "0"
    // 网络通畅尝试次数
    var netCount = 0
    // 第一次定制模型的尝试次数
    var firstAccessCount = 0
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        //        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        //        preferences.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        //        preferences.setValue(true, forKey: "allowFileAccess")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        
        //监听js
        //        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "callbackHandle")
        //        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "callbackHandle2")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "jumpPage")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "logMessage")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "saveStl")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "deleteStl")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "sendWifiPass")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "printerGcode")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "firstAccess")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "firstBuild")
        configuration.userContentController.add(WeakScriptMessageDelegate.init(self), name: "firstMyWorld")
        
        var webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
    
        
        return webView
    }()
    
    // let HTML = try! String(contentsOfFile: Bundle.main.path(forResource: "index", ofType: "html")!, encoding: String.Encoding.utf8)
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isTranslucent = false
        
        
        super.viewDidLoad()
        // title = "WebViewJS交互Demo"
        view.backgroundColor = .white
        view.addSubview(webView)
        
        view.translatesAutoresizingMaskIntoConstraints = Bool(truncating: 0);
        
        // wifi准备
        super.viewDidLoad()
        // self.isHiddenSwitch.setOn(false, animated: true);
        //self.ssidInputText.isUserInteractionEnabled = false;
        //self.ssidInputText.borderStyle =  UITextField.BorderStyle.none;
        self.hideKeyboardWhenTappedAround() ;
        
        if(codeStl == "-1" ){
            if(netCount < 3 && netFlag == "0"){
                checkServerNet()
            }
            if(StlDealTools.stlMap.count == 0){
                FileTools.getFromstlGcodeList()
            }
            
        }
        
        // screenWidth = self.view.frame.width      //the main screen size of width;
        // screenHeight = self.view.frame.height    //the main screen size of height;
        
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
        
        
        if(StringTools.isEmpty(str: message)){
//            loadHtml(htmlUrl: HtmlConfig.FIRST_WELCOME)
            checkAndJump(code: "-1")
        } else{
            checkAndJump(code: message)
        }
        
        
    }
    func checkRotation(code: String){
        print("screenWidth:")
        print(screenWidth)
        print("screenHeight:")
        print(screenHeight)
        
        firstAccessCount = 0;
        isFlag = false;
        beforeCode = codeStl;
        codeStl = code;
        StlDealTools.code = codeStl
        
        if(codeStl == "4"){
            if #available(iOS 11.0, *){
               self.webView.scrollView.contentInsetAdjustmentBehavior = .never;
           }
            isFlag = true
        } else{
            isFlag = false
            if #available(iOS 11.0, *){
               self.webView.scrollView.contentInsetAdjustmentBehavior = .always;
           }
        }
//        if(codeStl == "-1"){
//            if #available(iOS 11.0, *){
//               self.webView.scrollView.contentInsetAdjustmentBehavior = .never;
//           }
//            isFlag = false
//        }
        if(isFlag){
            let rotation : UIInterfaceOrientationMask = [.landscapeLeft, .landscapeRight]
            appDeleagte.blockRotation = rotation
            self.webView.frame = CGRect(x: 0, y: 0, width: screenHeight, height: screenWidth )
        } else{
            let rotation : UIInterfaceOrientationMask = [.portrait]
            appDeleagte.blockRotation = rotation
            self.webView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        StlDealTools.webView = webView
    
        print("----code"+codeStl+"-----")
        switch(codeStl){
            
        case "-1":
            
            var accessFlag = FileTools.getByPlist(keyName: ServerConfig.FIRST_ACCESS)
            if(StringTools.isEmpty(str: accessFlag)){
                accessFlag = "0"
            }
            var bulidFlag = FileTools.getByPlist(keyName: ServerConfig.FIRST_BUILD)
            if(StringTools.isEmpty(str: bulidFlag)){
                bulidFlag = "0"
            }
            
            var myWorldFlag = FileTools.getByPlist(keyName: ServerConfig.FIRST_MY_WORLD)
            if(StringTools.isEmpty(str: myWorldFlag)){
                myWorldFlag = "0"
            }
            
            webView.evaluateJavaScript("firstCheck('" + accessFlag + "','" + bulidFlag + "','" + myWorldFlag + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break
            
        case "0":
            PrinterConfig.setWifiInfo()
            
            let tempStr = StlDealTools.getLocalStl()
            webView.evaluateJavaScript("getDefaultStl('" + tempStr + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break
        case "1":
            let tempStr = StlDealTools.getStlList()
            webView.evaluateJavaScript("thisParamInfo(2,'" + tempStr + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break
        case "3":
            PrinterConfig.setWifiInfo()
            
            let tempStr = StlDealTools.getLocalStl()
            webView.evaluateJavaScript("getDefaultStl('" + tempStr + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break
        case "4":
            let tempStr = StlDealTools.getStlList()
            var bulidFlag = FileTools.getByPlist(keyName: ServerConfig.FIRST_BUILD)
            if(StringTools.isEmpty(str: bulidFlag)){
                bulidFlag = "0"
            }
            var myWorldFlag = FileTools.getByPlist(keyName: ServerConfig.FIRST_MY_WORLD)
            if(StringTools.isEmpty(str: myWorldFlag)){
                myWorldFlag = "0"
            }
            webView.evaluateJavaScript("getLocalAppSTL('" + tempStr + "','" + bulidFlag + "','" + myWorldFlag + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break
        case "5":
            let flag: Int = PrinterConfig.checkWifi()
            webView.evaluateJavaScript("connectStatus('" + String(flag) + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break
        case "6":
            let flag: Int = PrinterConfig.checkWifi()
            
            webView.evaluateJavaScript("menuCenterClean()") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            webView.evaluateJavaScript("connectStatus('" + String(flag) + "')") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break
        case "61":
            PrinterConfig.setWifiInfo()
            self.wirteWifiInfo()
            break
        case "66":
            webView.evaluateJavaScript("menuCenterClean()") { (response, error) in
                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break
        case "7":
            if(StringTools.isNotEmpty(str: PrinterConfig.LOCAL_GCODE) || StringTools.isNotEmpty(str: PrinterConfig.GEN_GCODE)){
                if(CacheUtil.sdGcodeMap.count == 0){
                    CacheUtil.getSDList(flag: 1)
                }
                var tempStlGcode: StlGcode = StlGcode()
                if(StringTools.isNotEmpty(str: PrinterConfig.LOCAL_GCODE)){
                    tempStlGcode = StlDealTools.localMapStl[PrinterConfig.LOCAL_GCODE]!
                } else if(StringTools.isNotEmpty(str: PrinterConfig.GEN_GCODE)){
                    tempStlGcode = StlDealTools.stlMap[PrinterConfig.GEN_GCODE]!
                }
                if(StringTools.isNotEmpty(str: tempStlGcode.localGcodeName!)){
                    PrinterConfig.STL_GCODE = tempStlGcode
                    WebHost.setPrinterInfo()
                    if(tempStlGcode.flag == 0){
                        self.beforePostTo3dPrinter(stlGcode: tempStlGcode)
                    } else{
                        printNow()
                    }
                }
            } else{
                print("no print gcode")
            }
            break;
        default:
            break
        }
        
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
        case "jumpPage":
            let code = message.body  as! String
            if(code == "5"){
                checkAndJump(code: beforeCode)
            } else{
                checkAndJump(code: code)
            }
            
            break
        case "logMessage":
            print(message.body)
            break
        case "saveStl":
            var fileTxt = ""
            var fileName = ""
            var imgData = ""
            
            if let dic = message.body as? NSDictionary{
                fileTxt = (dic["fileTxt"] as AnyObject).description
                fileName = (dic["fileName"] as AnyObject).description
                imgData = (dic["imgData"] as AnyObject).description
            }
            
            if(StringTools.isNotEmpty(str: fileTxt) && StringTools.isNotEmpty(str: fileName) && StringTools.isNotEmpty(str: imgData)){
                
                // 将 base64的图片字符串转化成Data
                let imageData2 = Data(base64Encoded: imgData)
                let image2 = UIImage.init(data: imageData2!)
                
                // 随机生成的唯一文件名称
                let randomFileName = FileTools.getRandomFilePath();
                
                
                var isSu = FileTools.createDir(dirPath: FileTools.printer3dPath)
                if(isSu){
                    // 保存图片信息
                    let imgName = FileTools.printer3dPath + "/" + randomFileName + ".png"
                    let shortName = randomFileName + ".png"
                    
                    print("imgName:")
                    print(imgName)
                    
                    do {
                        try image2!.pngData()?.write(to: URL(fileURLWithPath: imgName))
                    } catch  {
                        print(error)
                    }
                    isSu = FileManager.default.fileExists(atPath: imgName)
                    if(isSu){
                        // 文件copy到 APP_TEMP_PATH
                        isSu = FileTools.createDir(dirPath: FileTools.APP_TEMP_PATH)
                        if(isSu){
                            isSu = FileTools.copyFile(sourceUrl: imgName, targetUrl: FileTools.APP_TEMP_PATH + "/" + randomFileName + ".png")
                        }
                    }
                    
                    
                    if(isSu){
                        print("save img success:" + imgName)
                        // 图片也上传到服务器
                        let image = UIImage(named: imgName)
                        //将图片转化为JPEG类型的data 后面的参数是压缩比例
                        let pngImage = image!.pngData()
                        
                        isSu = WebHost.saveStl(fileTxt : fileTxt, fileName : fileName ,imgName : imgName, randomFileName : randomFileName, imgData: pngImage!, shortImgName: shortName)
                        print("saveStl:" + String(isSu))
                        
                        
                    } else{
                        print("save img errror")
                    }
                    
                    if(codeStl == "10"){
                        // 首次进入的成功直接跳转到我的模型，否则重试
                        if(isSu){
                            checkAndJump(code: "66")
                        } else {
                            firstAccessCount = firstAccessCount + 1
                            if(firstAccessCount < 3){
                                webView.evaluateJavaScript("confirmPrint()") { (response, error) in
                                    //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
                                }
                            } else{
                                checkAndJump(code: "3")
                            }
                        }
                    } else {
                        if(isSu){
                             let tempStr = StlDealTools.getStlList()
                            webView.evaluateJavaScript("afterSTLImg('" + tempStr + "')") { (response, error) in
                                            print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
                                        }
                        } else{
                            webView.evaluateJavaScript("saveImgFalse()") { (response, error) in
                                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
                            }
                        }
                    }
                    
                } else{
                    print("create img dir error")
                }
            }
            
            break
        case "deleteStl":
            // print("\(message.body)")
            let realName = message.body;
            let flag = StlDealTools.deleteStl(fileName: realName as! String);
            webView.evaluateJavaScript("deletedAfter("+String(flag)+")") { (response, error) in
                print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
            }
            break;
            
        case "sendWifiPass":
            // print("\(message.body)")
            let passWord = message.body as! String;
            
            if(StringTools.isNotEmpty(str: self.wifiInfo["ssid"]!) && StringTools.isNotEmpty(str: self.wifiInfo["bssid"]!)
                && StringTools.isNotEmpty(str: passWord)){
                
                print("ssid:")
                print(self.wifiInfo["ssid"]!)
                print("bssid:")
                print(self.wifiInfo["bssid"]!)
                print("password:")
                print(passWord)
                
                self.espController.delegate = self;
                self.showAlertWithResult(title:"Connetting...",message:"");
                self.espController.sendSmartConfig(bssid: self.wifiInfo["bssid"]!, ssid: self.wifiInfo["ssid"]!, password: passWord, resultExpected: Int32(self.resultExpected));
                
            }
            break;
            
        case "printerGcode":
            
            var moduleName = ""
            var type = ""
            
            if let dic = message.body as? NSDictionary{
                moduleName = (dic["moduleName"] as AnyObject).description
                type = (dic["type"] as AnyObject).description
            }
            
            if(type == "0"){
                PrinterConfig.LOCAL_GCODE = moduleName;
                PrinterConfig.GEN_GCODE = "";
            } else{
                PrinterConfig.LOCAL_GCODE = "";
                PrinterConfig.GEN_GCODE = moduleName;
            }
            
            if(StringTools.isNotEmpty(str: PrinterConfig.ESP_8266_URL)){
                checkAndJump(code: "7")
            } else{
                checkAndJump(code: "61")
            }
            
            break;
            
        case "firstAccess":
            var isSu = FileTools.saveToPlist(keyName: ServerConfig.FIRST_ACCESS, val: "1")
            if(!isSu){
                isSu = FileTools.saveToPlist(keyName: ServerConfig.FIRST_ACCESS, val: "1")
            }
            
            // 检查网络是否通畅
            
            if(netFlag == "1"){
                checkAndJump(code: "10")
            } else{
                let message = "Can Not Connect Server Please Try Again!"
                alertController = UIAlertController(title: title, message:
                    message, preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel,handler: {
                    action in self.checkAndJump(code: "3")
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            break;
            
        case "firstBuild":
            var isSu = FileTools.saveToPlist(keyName: ServerConfig.FIRST_BUILD, val: "1")
            if(!isSu){
                isSu = FileTools.saveToPlist(keyName: ServerConfig.FIRST_BUILD, val: "1")
            }
            break;
            
        case "firstMyWorld":
            var isSu = FileTools.saveToPlist(keyName: ServerConfig.FIRST_MY_WORLD, val: "1")
            if(!isSu){
                isSu = FileTools.saveToPlist(keyName: ServerConfig.FIRST_MY_WORLD, val: "1")
            }
            break;
            
        default: break
            
            
            
        }
        //print(message.body)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // 判断服务器采用的验证方法
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust){
            if(challenge.previousFailureCount == 0){
                // 如果没有错误的情况下，创建一个凭证，并且使用证书
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(.useCredential,  credential)
            } else{
                completionHandler(.cancelAuthenticationChallenge,  nil)
            }
        }else{
            completionHandler(.cancelAuthenticationChallenge,  nil)
        }
    }
    
    func checkAndJump(code : String){
        
        checkRotation(code: code);
        
        
        switch code {
        case "1":
            // 我的模型
            loadHtml(htmlUrl : HtmlConfig.MYMODULE_HTML)
            break;
        case "2":
            // 店铺
            loadHtml(htmlUrl : HtmlConfig.SHOP_HTML)
            break;
        case "3":
            // 首页
            loadHtml(htmlUrl : HtmlConfig.INDEX_HTML)
            break;
        case "4":
            loadHtml(htmlUrl : HtmlConfig.BULID_MODULE_URL)
            break;
        case "5":
            // 返回
            loadHtml(htmlUrl : HtmlConfig.PRINTER_INTRO_HTML)
            break;
        case "6":
            // 是否链接打印机
            loadHtml(htmlUrl : HtmlConfig.PRINTER_INTRO_HTML)
            break;
        case "61":
            // 设置ESPTouch界面
            loadHtml(htmlUrl : HtmlConfig.WIFI_PASS_HTML)
            break;
        case "66":
            // 第一次链接打印机
            loadHtml(htmlUrl : HtmlConfig.PRINTER_INTRO_FIRST_HTML)
            break;
        case "7":
            // 打印机状态界面
            loadHtml(htmlUrl : HtmlConfig.PRINTER_STATUS_HTML)
            break;
        case "8":
            loadHtml(htmlUrl : HtmlConfig.INDEX_HTML)
            break;
        case "9":
            // 欢迎页面
            loadHtml(htmlUrl : HtmlConfig.WELCOME_SLIDE)
            break;
        case "10":
            // 定制我的模型页面
            loadHtml(htmlUrl : HtmlConfig.CUSTOMIZE_HTML)
            break;
        case "-1":
            loadHtml(htmlUrl: HtmlConfig.FIRST_WELCOME)
            break;
        default:
            codeStl = "0"
        }
        
    }
    
    
    func loadHtml(htmlUrl : String){
        // 加载本地Html页面
        // let temoHtmlUrl = "https://www.baidu.com";
        guard let url = URL(string: htmlUrl) else {
            print("load html error!!!!!!!")
            return
        }
        let request = URLRequest(url: url)
        print("load html -----" + htmlUrl)
        webView.load(request)
        
    }
    
    
    
    func beforePostTo3dPrinter(stlGcode: StlGcode){
        if(StringTools.isNotEmpty(str: PrinterConfig.ESP_8266_URL)){
            postTo3dPrinter(stlGcode: stlGcode)
        } else{
            // 无记录或者打印机没有连接
            print("打印机没有连接")
            checkAndJump(code: "61")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //如果不设置该页面的竖屏， 在屏幕锁定打开的情况下，竖屏First -> 横屏Second -> 切换到后台 -> 进入前台 -> 返回竖屏First 会出现状态栏已竖屏，其他内容仍然横屏切换的问题
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    
    func wirteWifiInfo(){
        let ssid: String = self.wifiInfo["ssid"]!
        let bssid: String = self.wifiInfo["bssid"]!
        
        let jsStr = "wirteWifiInfo('" + ssid + "','" + bssid + "')"
        
        webView.evaluateJavaScript(jsStr) { (response, error) in
            print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
        }
    }
    
    func showAlertWithResult(title : String,  message: String){
        
        alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel,handler: {
            action in self.espController.interruptESP()
        }))
        
        self.okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {
            action in if(self.beforeCode == "66"){
                // 如果没有定制，则跳转到定制页面
                self.checkAndJump(code: "10")
                
            }else{
                if(StringTools.isNotEmpty(str: PrinterConfig.ESP_8266_URL) && (StringTools.isNotEmpty(str: PrinterConfig.GEN_GCODE) || StringTools.isNotEmpty(str: PrinterConfig.LOCAL_GCODE))){
                    self.checkAndJump(code: "7")
                } else{
                    self.checkAndJump(code: "5")
                }
            }
        })
        if let ok = self.okAction {
            ok.isEnabled = false
            alertController.addAction(ok)
            
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // 检查是否能连接服务器
    func checkServerNet(){
        var rs: String  = "";
        AlamofireTools.authSsl()
        AlamofireTools.sharedSessionManager.request(ServerConfig.CHECK_NET_URL).validate().responseData{(DDataRequest) in
            if DDataRequest.result.isSuccess {
                rs = String.init(data: DDataRequest.data!, encoding: String.Encoding.utf8)!
                print("getUrl:" + ServerConfig.CHECK_NET_URL + "--" + rs)
                // 调用成功，说明网络通畅
                self.netFlag = "1";
            }
            if DDataRequest.result.isFailure {
                self.netCount =  self.netCount + 1
                print("getUrl:" + ServerConfig.CHECK_NET_URL + "失败！！！")
            }
        }
    }
    
    // 上传到marlin打印机
    func postTo3dPrinter(stlGcode: StlGcode){
        if(FileTools.fileIsExists(path: stlGcode.localGcodeName!)){
            
            // ssl授权
            // AlamofireTools.authSsl()
            let url = URL(string: PrinterConfig.getPostFileUrl())
            
            
            print("url:" + url!.description)
            
            var headers = [String: String]()
            headers["Content-Type"] = "multipart/form-data"
            headers["Connection"] = "keep-alive"
            headers["Accept"] = "*/*"
            headers["User-Agent"] = "Mozilla/5.0 (Windows Nt 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
            
            let fileSize = StlDealTools.getSize(filePath: stlGcode.localGcodeName!)
            headers["Content-Length"] = String(fileSize)
            
            print(headers.description)
            
//            webView.evaluateJavaScript("changeTopStatus(0)") { (response, error) in
//                //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
//            }
            
            //AlamofireTools.sharedSessionManagerEsp.upload(Data.init(referencing: upData!), to: url!, method: .post, headers: headers)
            
            AlamofireTools.sharedSessionManager.upload(multipartFormData: { (multipartFormData) in
                // Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                let upData = NSData.init(contentsOfFile: stlGcode.localGcodeName!)
                let mimeType = FileTools.mimeType(pathExtension: stlGcode.localGcodeName!)
                
                var shortName = stlGcode.sourceStlName!
                
                shortName = StringTools.replaceString(str: shortName, subStr: ".stl", replaceStr: ".gco")
                print("mimeType:" + mimeType)
                print("shortName:" + shortName)
                multipartFormData.append(Data.init(referencing: upData!), withName: "file", fileName: shortName, mimeType: mimeType)
                
            }, to: url!) { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) in
                        if let responSEObject = response.result.value{
                            print("responSEObject")
                            print(responSEObject)
                            
                            if let jsonResult = responSEObject as? Dictionary<String,AnyObject> {
                                // do whatever with jsonResult
                                let rs = (jsonResult["status"] as! String).lowercased()
                                if(StringTools.isNotEmpty(str: rs) && (rs.contains("OK") || rs.contains("ok"))){
                                    // 上传成功，开始打印
                                    // 更新上传成功标示
                                    stlGcode.flag = 1
                                    StlDealTools.saveStlInfo(realFilePath: stlGcode.realStlName!, stlGcode: stlGcode)
                                    self.printNow()
                                } else{
                                    // 上传失败
                                    print("上传失败")
                                }
                            } else{
                                print("上传返回结果异常")
                            }
                        }
                    })
                case .failure:
                    print("网络异常")
                }
            }
            
            
        } else{
            // 本地文件找不到
            print("本地文件找不到")
        }
    }
    
   
    
    // 调用marlin命令进行打印
    func printNow(){
        var rs: String  = "";
        let tempGcode = PrinterConfig.STL_GCODE?.sourceStlName
        let printTime = PrinterConfig.STL_GCODE?.exeTime
        let gcodeName = StringTools.replaceString(str: tempGcode!, subStr: "stl", replaceStr: "gco")
        print("tempGcode:" + tempGcode!)
        print("gcodeName:" + gcodeName)
        
        let tempUrl = PrinterConfig.getPrinterCommond(gcodeName: gcodeName)
        
        print("tempUrl:" + tempUrl)
        
        // ssl授权
        // AlamofireTools.authSsl()
        Alamofire.request(tempUrl).validate().responseData{ [self](DDataRequest) in
            if DDataRequest.result.isSuccess {
                rs = String.init(data: DDataRequest.data!, encoding: String.Encoding.utf8)!
                print("getUrl:" + tempUrl + "--" + rs)
                // 调用成功，准备打印
                webView.evaluateJavaScript("changeTopStatus(1)") { (response, error) in
                    //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
                }
                webView.evaluateJavaScript("countDown('" + String(printTime!) + "')") { (response, error) in
                    //print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
                }
            }
            if DDataRequest.result.isFailure {
                print("getUrl:" + tempUrl + "失败！！！")
            }
        }
    }
    
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "jumpPage")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "logMessage")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "saveStl")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "deleteStl")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "sendWifiPass")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "printerGcode")
        
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "firstAccess")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "firstBuild")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "firstMyWorld")
        
        
        print("WKWebViewController is deinit")
    }
    
    
}
