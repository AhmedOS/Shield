//
//  ScanFileVC.swift
//  Shield
//
//  Created by Ahmed Osama on 12/2/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class ScanFileVC: UIViewController {

    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var selectFileButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var filesManager: FilesManager!
    var fileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filesManager = FilesManager()
        filesManager.userPickedFiles = {
            if let url = self.filesManager.pickedfilesURLs.first {
                self.fileURL = url
                DispatchQueue.main.async {
                    self.fileNameLabel.text = url.lastPathComponent
                    self.scanButton.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func selectFileButtonTapped(_ sender: Any) {
        filesManager.presentDocumentPicker(viewController: self)
    }
    
    @IBAction func scanButtonTapped(_ sender: Any) {
        if let url = fileURL {
            processFile(url: url)
        }
    }
    
    func processFile(url: URL) {
        let maxFileSize = 33554432 //32MB
        let fileSize = FilesManager.getFileSize(fileURL: url)
        if fileSize == 0 {
            Helpers.showSimpleAlert(viewController: self, title: "Error", message: "Failed to get file size")
        }
        else if fileSize > maxFileSize {
            Helpers.showSimpleAlert(viewController: self, title: "Error",
                                    message: "File size exceeds the maximum limit (32 megabytes)")
        }
        else {
            enableUI(false)
            VirustotalClient.scan(fileURL: url) { (result) in
                self.enableUI(true)
                switch result {
                case .apiLimitExceeded:
                    Helpers.showSimpleAlert(viewController: self, title: "Server busy", message: result.rawValue)
                case .queued:
                    Helpers.showSimpleAlert(viewController: self, title: "Queued", message: result.rawValue)
                    self.resetState()
                    self.tabBarController?.selectedIndex = 1
                case .unknown, .unexpectedResponse:
                    Helpers.showSimpleAlert(viewController: self, title: "Error", message: result.rawValue)
                }
            }
        }
    }
    
    func resetState() {
        DispatchQueue.main.async {
            self.fileURL = nil
            self.fileNameLabel.text = "-No File Picked-"
            self.scanButton.isEnabled = false
        }
    }
    
    func enableUI(_ enabled: Bool) {
        selectFileButton.isEnabled = enabled
        scanButton.isEnabled = enabled
        enabled ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
    
}
