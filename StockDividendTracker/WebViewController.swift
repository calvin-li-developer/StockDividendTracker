//
//  WebViewController.swift
//  StockDividendTracker
//
//  Created by Calvin Li on 2021-04-05.
//

import UIKit
import WebKit
class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView : WKWebView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let index = StockList.get.index
        let stock = StockList.get.stocks[index]
        
        title = "Yahoo Finance - \(stock.getTicker())"
        navigationController?.setToolbarHidden(false, animated: false)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        webView.allowsBackForwardNavigationGestures = true
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.webView)
        
        self.webView.frame = CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.webView.navigationDelegate = self
        self.webView.load(URLRequest(url: NSURL(string: stock.getWebURL())! as URL))
        // Do any additional setup after loading the view.
    }
    
    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        NSLog("Start")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NSLog("Failed Navigation %@", error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Finish navigation
        print("Finish Navigation")
        print("Title:%@ URL:%@", webView.title!, webView.url!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @IBAction func leftButtonClick(_ sender: Any) {
        self.webView.goBack()
    }
    @IBAction func rightButtonClick(_ sender: Any) {
        self.webView.goForward()
    }
    @IBAction func refreshClick(_ sender: Any) {
        self.webView.reload()
    }
}
