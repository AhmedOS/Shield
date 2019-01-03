//
//  Helpers.swift
//  Shield
//
//  Created by Ahmed Osama on 12/3/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import UIKit

enum Helpers {
    
    static let sharedCache = NSCache<NSString, UIImage>()
    
    static func showSimpleAlert(viewController: UIViewController, title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    static func getFileName(from url: URL) -> String {
        return url.lastPathComponent
    }
    
}
