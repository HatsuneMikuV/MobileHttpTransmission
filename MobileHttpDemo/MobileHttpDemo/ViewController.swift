//
//  ViewController.swift
//  MobileHttpDemo
//
//  Created by mbp13 on 2020/7/30.
//  Copyright © 2020 Anglemiku. All rights reserved.
//

import UIKit
import GCDWebServer
import Alamofire
import SVProgressHUD

class ViewController: UIViewController {
  
  @IBOutlet weak var httpIPLabel: UILabel!
  
  @IBOutlet weak var contentTxt: UITextField!
  
  @IBOutlet weak var resultLabel: UILabel!
  
  @IBOutlet weak var photoView: UIImageView!
  
  @IBOutlet weak var sendBtn: UIButton!
  
  @IBOutlet weak var tipsLabel: UILabel!
  
  @IBOutlet weak var createBtn: UIButton!
  
  @IBOutlet weak var chooseBtn: UIButton!
  
  var sendDataUrl:String?
  
  var webServer:GCDWebServer?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    SVProgressHUD.setMaximumDismissTimeInterval(2)
    AF.sessionConfiguration.timeoutIntervalForRequest = 15
    AF.sessionConfiguration.timeoutIntervalForRequest = 15
  }
  
  @IBAction func createSever(_ sender: Any) {
    self.createBtn.isSelected = !self.createBtn.isSelected
    view.endEditing(true)
    if self.createBtn.isSelected {
      self.createBtn.setTitle("关闭服务器", for: .normal)
      if self.webServer == nil {
        let webServer = GCDWebServer()
        webServer.delegate = self
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, asyncProcessBlock: { (request, completionBlock) in
          
          /// do something
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            var content = "Test data"
            if let str = self.contentTxt.text, str.count > 0 {
              content = str
            }
            let response = GCDWebServerDataResponse.init(text: content)
            completionBlock(response)
          })
        })
        
        webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
        print("The service started successfully: \(webServer.serverURL)")
        if webServer.serverURL == nil {
          webServer.stop()
          self.createBtn.isSelected = false
          self.createBtn.setTitle("创建服务器", for: .normal)
          SVProgressHUD.showError(withStatus: "Please check mobile wifi!!!")
        } else {
          self.httpIPLabel.text = "ip or http: " + String(webServer.serverURL?.absoluteString ?? "")
          self.webServer = webServer
          self.sendBtn.isHidden = true
          self.tipsLabel.isHidden = true
          self.resultLabel.isHidden = true
        }
        self.httpIPLabel.isHidden = false
        self.chooseBtn.isHidden = false
      } else {
        SVProgressHUD.showError(withStatus: "Created!!!")
      }
    } else {
      self.createBtn.setTitle("创建服务器", for: .normal)
      if self.webServer == nil {
        SVProgressHUD.showError(withStatus: "Closed!!!")
      } else {
        self.webServer?.stop()
        self.webServer = nil
        self.httpIPLabel.text = "ip or http: ???"
        self.sendBtn.isHidden = false
        self.tipsLabel.isHidden = false
        self.resultLabel.isHidden = false
        self.httpIPLabel.isHidden = false
        self.chooseBtn.isHidden = false
      }
    }
  }
  
  @IBAction func sendData(_ sender: Any) {
    view.endEditing(true)
    self.httpIPLabel.isHidden = true
    self.chooseBtn.isHidden = true
    if self.contentTxt.text?.count ?? 0 > 0 {
      AF.request(self.contentTxt.text!).responseString(completionHandler: { (response) in
        switch response.result {
        case .success(let json):
          self.resultLabel.text = json
          break
        case .failure(_):
          self.resultLabel.text = "request error"
          break
        }
      })
    } else {
      SVProgressHUD.showError(withStatus: "Please enter the URL")
    }
  }
  
  @IBAction func choosePhoto(_ sender: Any) {
    
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
}


extension ViewController:GCDWebServerDelegate {
  
  func webServerDidStart(_ server: GCDWebServer) {
    print("webServerDidStart===========\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  
  func webServerDidCompleteBonjourRegistration(_ server: GCDWebServer) {
    print("webServerDidCompleteBonjourRegistration===========\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  func webServerDidConnect(_ server: GCDWebServer) {
    print("webServerDidConnect===========\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  
  func webServerDidDisconnect(_ server: GCDWebServer) {
    print("webServerDidDisconnect===========\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  
  func webServerDidStop(_ server: GCDWebServer) {
    print("webServerDidStop===========\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  
  func webServerDidUpdateNATPortMapping(_ server: GCDWebServer) {
    print("webServerDidUpdateNATPortMapping===========\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  
}
