//
//  FilesEncryptionVC.swift
//  Shield
//
//  Created by Ahmed Osama on 12/21/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import CryptoSwift

class FilesEncryptionVC: UIViewController {

    @IBOutlet weak var pickFileButton: UIButton!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var encryptButton: UIButton!
    @IBOutlet weak var decryptButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var filesManager: FilesManager!
    var fileURL: URL?
    
    enum CryptoMode {
        case encrypt, decrypt
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.delegate = self
        filesManager = FilesManager()
        filesManager.userPickedFiles = {
            if let url = self.filesManager.pickedfilesURLs.first {
                self.fileURL = url
                DispatchQueue.main.async {
                    self.fileNameLabel.text = url.lastPathComponent
                    self.encryptButton.isEnabled = true
                    self.decryptButton.isEnabled = true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func pickFileButtonTapped(_ sender: Any) {
        filesManager.presentDocumentPicker(viewController: self)
    }
    
    @IBAction func encryptButtonTapped(_ sender: Any) {
        guard passwordTextField.text != "" else {
            Helpers.showSimpleAlert(viewController: self, title: "Error", message: "Empty password")
            return
        }
        enableUIControls(false)
        if let path = fileURL {
            let password = passwordTextField.text!
            DispatchQueue.global(qos: .background).async {
                let error = self.cryptFile(mode: .encrypt, fileURL: path, password: password)
                DispatchQueue.main.async {
                    self.enableUIControls(true)
                }
                if let error = error {
                    Helpers.showSimpleAlert(viewController: self, title: "Error", message: error)
                }
                else {
                    Helpers.showSimpleAlert(viewController: self, title: "Success", message: "File encrypted successfully.")
                }
            }
        }
    }
    
    @IBAction func decryptButtonTapped(_ sender: Any) {
        guard passwordTextField.text != "" else {
            Helpers.showSimpleAlert(viewController: self, title: "Error", message: "Empty password")
            return
        }
        enableUIControls(false)
        if let path = fileURL {
            let password = passwordTextField.text!
            DispatchQueue.global(qos: .background).async {
                let error = self.cryptFile(mode: .decrypt, fileURL: path, password: password)
                DispatchQueue.main.async {
                    self.enableUIControls(true)
                }
                if let error = error {
                    Helpers.showSimpleAlert(viewController: self, title: "Error", message: error)
                }
                else {
                    Helpers.showSimpleAlert(viewController: self, title: "Success", message: "File decrypted successfully. Note that using wrong password will generate invalid file.")
                }
            }
        }
    }
    
    func getFileSize(fileURL: URL) -> UInt64 {
        var fileSize : UInt64 = 0
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        }
        catch {
            print("Error: \(error)")
        }
        return fileSize
    }
    
    func updateProgressView(_ value: Float) {
        DispatchQueue.main.async {
            self.progressView.progress = value
        }
    }
    
    func getUniqueName(fileURL: URL) -> String {
        let time = Int(Date().timeIntervalSince1970)
        let name = fileURL.deletingPathExtension().lastPathComponent
        let ext = fileURL.pathExtension
        var fileName = "\(name)_\(time)"
        if ext != "" {
            fileName.append(contentsOf: ".\(ext)")
        }
        return fileName
    }
    
    func generateBigFile() {
        do {
            let outputURL = FilesManager.Folder.encrypted.url(fileName: "bigFile")
            filesManager.createFile(fileURL: outputURL)
            var total = 0
            let outputHandler = try FileHandle(forWritingTo: outputURL)
            while total < 5000000 {
                let data = "\(Date().timeIntervalSince1970)".data(using: .utf8)!
                outputHandler.write(data)
                total += data.count
            }
        }
        catch {
            return
        }
    }
    
    func cryptFile(mode: CryptoMode, fileURL: URL, password: String) -> String? {
        let totalSize = getFileSize(fileURL: fileURL)
        var done: UInt64 = 0
        let key = ((password.data(using: .utf8)?.sha256())!).bytes
        var iv = [UInt8]()
        for i in stride(from: 0, to: key.count, by: 2) {
            iv.append(key[i])
        }
        do {
            var cryptor: (Cryptor & Updatable)!
            var outputFolder: FilesManager.Folder
            switch mode {
            case .encrypt:
                cryptor = try AES(key: key, blockMode: CBC(iv: iv)).makeEncryptor()
                outputFolder = .encrypted
            case .decrypt:
                cryptor = try AES(key: key, blockMode: CBC(iv: iv)).makeDecryptor()
                outputFolder = .decrypted
            }
            let length = 40000
            //let inputSream = InputStream(url: fileURL)
            let inputHandler = try FileHandle(forReadingFrom: fileURL)
            let fileName = getUniqueName(fileURL: fileURL)
            let outputURL = outputFolder.url(fileName: fileName)
            filesManager.createFile(fileURL: outputURL)
            let outputHandler = try FileHandle(forWritingTo: outputURL)
            while true {
                let data = inputHandler.readData(ofLength: length)
                guard data.count != 0 else {
                    let resultData = try cryptor.finish()
                    outputHandler.write(Data(resultData))
                    break
                }
                let resultData = try cryptor.update(withBytes: data.bytes)
                outputHandler.write(Data(resultData))
                done += UInt64(data.count)
                updateProgressView(Float(done) / Float(totalSize))
            }
        }
        catch let error {
            return error.localizedDescription
        }
        return nil
    }
    
    
    func enableUIControls(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.pickFileButton.isEnabled = enabled
            self.passwordTextField.isEnabled = enabled
            self.encryptButton.isEnabled = enabled
            self.decryptButton.isEnabled = enabled
            if enabled {
                self.progressView.isHidden = true
            }
            else {
                self.progressView.progress = 0
                self.progressView.isHidden = false
            }
        }
    }
    
}

// Keyboard handling
extension FilesEncryptionVC {
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= 100
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
}

extension FilesEncryptionVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
