//
//  FilesManager.swift
//  Shield
//
//  Created by Ahmed Osama on 12/3/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import MobileCoreServices

class FilesManager: NSObject {
    
    fileprivate(set) var pickedfilesURLs = Set<URL>()
    var userPickedFiles: (() -> Void)?
    
    enum Folder: String {
        case encrypted = "Encrypted"
        case decrypted = "Decrypted"
        func url(fileName: String = "") -> URL {
            var url =  try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            url.appendPathComponent(self.rawValue)
            url.appendPathComponent(fileName)
            return url
        }
    }
    
    func checkAndCreateDirectories() {
        let directories = [Folder.encrypted, Folder.decrypted]
        for directory in directories {
            let url = directory.url()
            let exists = FileManager.default.fileExists(atPath: url.path)
            if !exists {
                do {
                    try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
                }
                catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
        }
    }
    
    func createFile(fileURL: URL) {
        checkAndCreateDirectories()
        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
    }
    
    func presentDocumentPicker(viewController: UIViewController) {
        let types = [String(kUTTypeData)]
        let browser = UIDocumentPickerViewController(documentTypes: types, in: .open)
        //browser.allowsMultipleSelection = true
        browser.delegate = self
        viewController.present(browser, animated: true, completion: nil)
    }
    
    static func getFileSize(fileURL: URL) -> UInt64 {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            return attr[FileAttributeKey.size] as! UInt64
        }
        catch {
            return 0
        }
    }
    
}

extension FilesManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pickedfilesURLs.removeAll() //one time selection
        for url in urls {
            pickedfilesURLs.insert(url)
        }
        userPickedFiles?()
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        pickedfilesURLs.removeAll()
    }
}
