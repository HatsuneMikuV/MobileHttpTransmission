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
  }
  
  @IBAction func createSever(_ sender: Any) {
    view.endEditing(true)
    if self.webServer == nil {
      let webServer = GCDWebServer()
      webServer.delegate = self
      webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, asyncProcessBlock: { (request, completionBlock) in
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
          
          let response = GCDWebServerDataResponse(html: self.contentTxt.text ?? "Test data")
          completionBlock(response)
          
        })
      })
      
      webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
      print("The service started successfully: \(webServer.serverURL!)")
      self.httpIPLabel.text = "ip or http: " + webServer.serverURL!.absoluteString
      self.webServer = webServer
      self.sendBtn.isHidden = true
      self.tipsLabel.isHidden = true
      self.resultLabel.isHidden = true
    } else {
      SVProgressHUD.showError(withStatus: "Created!!!")
    }
  }
  
  @IBAction func sendData(_ sender: Any) {
    view.endEditing(true)
    self.httpIPLabel.isHidden = true
    self.chooseBtn.isHidden = true
    self.createBtn.isHidden = true
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
  func webServerDidStop(_ server: GCDWebServer) {
    print("webServerDidStop===========")
    print("1======\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  func webServerDidStart(_ server: GCDWebServer) {
    print("webServerDidStart===========")
    print("2======\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  func webServerDidConnect(_ server: GCDWebServer) {
    print("webServerDidConnect===========")
    print("3======\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  func webServerDidDisconnect(_ server: GCDWebServer) {
    print("webServerDidDisconnect===========")
    print("4======\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  func webServerDidUpdateNATPortMapping(_ server: GCDWebServer) {
    print("webServerDidUpdateNATPortMapping===========")
    print("5======\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
  func webServerDidCompleteBonjourRegistration(_ server: GCDWebServer) {
    print("webServerDidCompleteBonjourRegistration===========")
    print("6======\nport: \(server.port) \nbonjourName: \(server.bonjourName)\n bonjourServerURL: \(server.bonjourServerURL) \nbonjourType: \(server.bonjourType)\npublicServerURL: \(server.publicServerURL)\nserverURL: \(server.serverURL)")
  }
}
