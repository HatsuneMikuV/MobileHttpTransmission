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
  var webUploader:GCDWebUploader?
  
  
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
      self.createBtn.setTitle("Close Sever", for: .normal)
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
        print("The GCDWebServer started successfully: \(webServer.serverURL)")
        if webServer.serverURL == nil {
          webServer.stop()
          self.createBtn.isSelected = false
          self.createBtn.setTitle("Create Sever", for: .normal)
          SVProgressHUD.showError(withStatus: "Please check mobile wifi!!!")
        } else {
          self.httpIPLabel.text = "GCDWebServer: " + String(webServer.serverURL?.absoluteString ?? "")
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
      self.createBtn.setTitle("Create Sever", for: .normal)
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
          if json.contains(".jpg") {
            self.download(json)
          }
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
  
  
  func download(_ url:String) {
    let header = self.contentTxt.text!.replacingOccurrences(of: "8080", with: "8081")
    let URL = header + "download?path=" + url
    print("URL == ", URL)
    AF.download(URL).responseData { (response) in
      switch response.result {
      case .success(let data):
        self.photoView.image = UIImage.init(data: data)
        break
      case .failure(_):
        self.resultLabel.text = "request error"
        self.photoView.backgroundColor = .red
        break
      }
    }
  }
  
  @IBAction func choosePhoto(_ sender: Any) {
    if self.webUploader == nil {
      //默认上传目录是App的用户文档目录
      let documentsPath = NSHomeDirectory() + "/Documents/images"
      let webUploader = GCDWebUploader(uploadDirectory: documentsPath)
      webUploader.delegate = self
      webUploader.start(withPort: 8081, bonjourName: "Web Based Uploads")
      print("The GCDWebUploader started successfully：\(webUploader.serverURL)")
      self.httpIPLabel.text = "GCDWebUploader: " + String(webUploader.serverURL?.absoluteString ?? "")
      self.webUploader = webUploader
    } else {
      SVProgressHUD.showError(withStatus: "Created!!!")
    }
    let imageController = UIImagePickerController.init()
    imageController.allowsEditing = true
    imageController.delegate = self
    present(imageController, animated: true)
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

extension ViewController : GCDWebUploaderDelegate {
  func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
    print("didDeleteItemAtPath === ", path)
  }
  
  func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
    print("didUploadFileAtPath === ", path)
  }
  
  func webUploader(_ uploader: GCDWebUploader, didDownloadFileAtPath path: String) {
    print("didDownloadFileAtPath === ", path)
  }
  
  func webUploader(_ uploader: GCDWebUploader, didCreateDirectoryAtPath path: String) {
    print("didCreateDirectoryAtPath === ", path)
  }
  
  func webUploader(_ uploader: GCDWebUploader, didMoveItemFromPath fromPath: String, toPath: String) {
    print("didMoveItemFromPath === ", fromPath, toPath)
  }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.editedImage] as? UIImage else { return }
    self.photoView.image = image
    if let jpegData = image.jpegData(compressionQuality: 0.8) {
      let (url, suc) = ViewController.saveDataWithFolder(source: jpegData as NSData, folder: "images", type: "jpg")
      if suc {
        self.contentTxt.text = url
      }
    }
    dismiss(animated: true)
  }
  
  static func saveDataWithFolder(source:NSData, folder:String, type:String) -> (String, Bool) {
    if source.count <= 0 || folder.count <= 0 {
      return ("", false)
    }
    let formater = DateFormatter()
    formater.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSS"
    let fileName = formater.string(from: Date()) + "." + type
    
    let paths:Array = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    guard let documentPath = paths.first else { return ("", false) }
    let fileManager = FileManager.default
    let fileDocPath = URL(fileURLWithPath: documentPath).appendingPathComponent(folder)
    let isExit = fileManager.fileExists(atPath: fileDocPath.path)
    if !isExit {
      do {
        try fileManager.createDirectory(at: fileDocPath, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("file path crate fail : \(fileDocPath)")
        return ("", false)
      }
    }
    let filePath = fileDocPath.appendingPathComponent(fileName)
    let result = source.write(to: filePath, atomically: true)
    if result {
      return (filePath.lastPathComponent, true)
    }
    return ("", false)
  }
  
}
