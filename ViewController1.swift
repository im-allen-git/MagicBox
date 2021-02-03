import UIKit
import WebKit
class ViewController1: UIViewController {
    
    var accessUrl = "http://192.168.1.163:8080/examples/src/3DPrinting.html"
    
    var webView = WKWebView()
    
    var btnBig: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.progressView.frame = CGRect(x:0,y:64,width:self.view.frame.size.width,height:2)
        self.progressView.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.progressView.progress = 0.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 35))
        view.addSubview(webView)
        webView.navigationDelegate = self
        let mapwayURL = URL(string: accessUrl)!
        let mapwayRequest = URLRequest(url: mapwayURL)
        webView.load(mapwayRequest)
        
        view.addSubview(self.progressView)
        
        addBigButton()
        addLitButton()
    }
    
    func addBigButton(){
        let newButton:UIButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 30, width: 70, height: 30))
        newButton.backgroundColor = UIColor.red
        newButton.setTitle("放大", for: .normal)
        newButton.addTarget(self, action: #selector(bigButtonAction), for: .touchUpInside)
        self.view.addSubview(newButton)
    }
    
    
    /// 响应按钮点击事件
    @objc func bigButtonAction(sender: UIButton) {
        print(sender.tag)
        self.webView.evaluateJavaScript("cameraSides(7)", completionHandler: {
            (any, error) in
            if (error != nil) {
                print(error)
            }
        })
    }
    
    
    func addLitButton(){
        let newButton:UIButton = UIButton(frame: CGRect(x: 90, y: self.view.frame.size.height - 30, width: 70, height: 30))
        newButton.backgroundColor = UIColor.red
        newButton.setTitle("缩小", for: .normal)
        newButton.addTarget(self, action: #selector(litButtonAction), for: .touchUpInside)
        self.view.addSubview(newButton)
    }
    
    
    /// 响应按钮点击事件
    @objc func litButtonAction(sender: UIButton) {
        print(sender.tag)
        self.webView.evaluateJavaScript("cameraSides(8)", completionHandler: {
            (any, error) in
            if (error != nil) {
                print(error)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 进度条
    lazy var progressView:UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.orange
        progress.trackTintColor = .clear
        return progress
    }()
    
}

extension ViewController:WKNavigationDelegate{
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        self.navigationItem.title = "加载中..."
        /// 获取网页的progress
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = Float(self.webView.estimatedProgress)
        }
    }
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        
    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        /// 获取网页title
        self.title = self.webView.title
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 1.0
            self.progressView.isHidden = true
        }
        
    }
    
    
    
    
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 0.0
            self.progressView.isHidden = true
        }
        /// 弹出提示框点击确定返回
        let alertView = UIAlertController.init(title: "提示", message: "加载失败", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:"确定", style: .default) { okAction in
            _=self.navigationController?.popViewController(animated: true)
        }
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
        
    }
    
}
