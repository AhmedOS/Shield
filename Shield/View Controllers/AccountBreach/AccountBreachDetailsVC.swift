//
//  AccountBreachDetailsVC.swift
//  Shield
//
//  Created by Ahmed Osama on 12/17/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class AccountBreachDetailsVC: UIViewController {
    
    var breach: Breach!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var breachDetails: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = Helpers.sharedCache.object(forKey: breach.logoPath! as NSString)
        logoImageView.image = image
        titleLabel.text = breach.title
        var data = breach.dataClasses.first!
        for s in breach.dataClasses {
            if s == data {
                continue
            }
            data += ", " + s
        }
        var description = breach.description!
        description = description.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
        description = description.stringByDecodingHTMLEntities
        breachDetails.text = "Domain: \(breach.domain!)\n\nBreach Date: \(breach.breachDate!)\n\nBreached Data: \(data)\n\nBreach Description:\n\(description)"
    }

}
