//
//  ViewController.swift
//  Encryptor
//
//  Created by yubin on 2019/12/26.
//  Copyright © 2019 yubin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var keyTextField: NSTextField!
    @IBOutlet weak var fileNameTextField: NSTextField!
    
    @IBOutlet weak var clearLabel: NSTextField!
    @IBOutlet weak var cipherLabel: NSTextField!
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var useOriginalName: NSButton!
    
    var clearFilePath: URL?
    var cipherFilePath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func selectClearFile(_ sender: NSButton) {
        clearFilePath = selectFile()
        clearLabel.stringValue = clearFilePath?.absoluteString ?? "-"
    }
    
    @IBAction func selectCipherFile(_ sender: Any) {
        cipherFilePath = selectFile()
        cipherLabel.stringValue = cipherFilePath?.absoluteString ?? "-"
    }
    
    @IBAction func encrypt(_ sender: NSButton) {
        print(useOriginalName.state.rawValue)
        guard let clearURL = clearFilePath else {
            alertMessage("未选择明文文件")
            return
        }
        
        guard let cipherURL = cipherFilePath else {
            alertMessage("未选择密文存储路径")
            return
        }
        
        let key = keyTextField.stringValue
        
        guard !key.isEmpty else {
            alertMessage("密钥不能为空")
            return
        }
        
        var fileName = fileNameTextField.stringValue
        if useOriginalName.state.rawValue == 1 {
            fileName = clearURL.lastPathComponent + ".c"
        }
        
        guard !fileName.isEmpty else {
            alertMessage("文件名不能为空")
            return
        }
        
        let des = cipherURL.appendingPathComponent(fileName)
        
        cipherLabel.stringValue = des.absoluteString
        
        startIndicator()
        DispatchQueue.global().async {
            do {
                try Encryptor.encrypt(file: clearURL, key: key, write: des)
            } catch  {
                self.alertMessage("加密文件出错: \(error.localizedDescription)")
                self.stopIndicator()
                return
            }
            
            self.stopIndicator()
            self.alertMessage("加密成功")
        }
    }
    
    @IBAction func decrypt(_ sender: NSButton) {
        guard let clearURL = clearFilePath else {
            alertMessage("未选择明文文件存储路径")
            return
        }
        
        guard let cipherURL = cipherFilePath else {
            alertMessage("未选择密文文件")
            return
        }
        
        let key = keyTextField.stringValue
        
        guard !key.isEmpty else {
            alertMessage("密钥不能为空")
            return
        }
        
        var fileName = fileNameTextField.stringValue
        if useOriginalName.state.rawValue == 1 {
            fileName = cipherURL.lastPathComponent
            if fileName.hasSuffix(".c") {
                fileName.removeLast(2)
            }
        }
        
        guard !fileName.isEmpty else {
            alertMessage("文件名不能为空")
            return
        }
        
        let des = clearURL.appendingPathComponent(fileName)
        
        clearLabel.stringValue = des.absoluteString
        
        startIndicator()
        DispatchQueue.global().async {
            do {
                try Encryptor.decrypt(file: cipherURL, key: key, write: des)
            } catch  {
                self.alertMessage("解密文件出错: \(error.localizedDescription)")
                self.stopIndicator()
                return
            }
            self.stopIndicator()
            self.alertMessage("解密成功")
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.isHidden = false
            self.indicator.startAnimation(nil)
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimation(nil)
            self.indicator.isHidden = true
        }
    }
    
    
    func selectFile() -> URL? {
        let openpanel = NSOpenPanel()
        openpanel.canChooseFiles = true
        openpanel.canChooseDirectories = true
        if openpanel.runModal() == .OK {
            return openpanel.url
        }
        return nil
    }
    
    func selectDirectory() -> URL? {
        let openpanel = NSOpenPanel()
        openpanel.canChooseFiles = true
        openpanel.canChooseDirectories = true
        if openpanel.runModal() == .OK {
            return openpanel.url
        }
        return nil
    }
    
    func alertMessage(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = message
            
            alert.addButton(withTitle: "知道了")
            alert.alertStyle = .warning
            if let keywindow = NSApplication.shared.keyWindow {
                alert.beginSheetModal(for: keywindow)
            }
        }
    }
}

