//
//  PasswordBreachVC.swift
//  Shield
//
//  Created by Ahmed Osama on 12/17/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class PasswordBreachVC: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        guard passwordTextField.text != "" else {
            Helpers.showSimpleAlert(viewController: self, title: "Error", message: "Empty password")
            return
        }
        enableUIControls(false)
        PwnedClient.requestPasswordBreach(passwordTextField.text!) { (seenCount, errorMessage) in
            self.enableUIControls(true)
            guard let count = seenCount else {
                Helpers.showSimpleAlert(viewController: self, title: "Error", message: errorMessage!)
                return
            }
            if count == 0 {
                Helpers.showSimpleAlert(viewController: self, title: "Good news!", message: "We didn't find the password in our database. Note that doesn't necessarily mean it's a good password.")
            }
            else {
                Helpers.showSimpleAlert(viewController: self, title: "Uh oh!!", message: "This password has been seen \(count) time\(count == 1 ? "" : "s").")
            }
        }
    }
    
    func enableUIControls(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.passwordTextField.isEnabled = enabled
            self.checkButton.isEnabled = enabled
            enabled ? self.activityIndicator.stopAnimating() : self.activityIndicator.startAnimating()
        }
    }
    
}

extension PasswordBreachVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
