//
//  AccountBreachVC.swift
//  Shield
//
//  Created by Ahmed Osama on 12/17/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class AccountBreachVC: UIViewController {
    
    let breachesResultVCSegueID = "showBreaches"
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var breaches: [Breach]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breaches = nil
        usernameTextField.text = ""
        enableUIControls(true)
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        guard usernameTextField.text != "" else {
            Helpers.showSimpleAlert(viewController: self, title: "Error", message: "Email/Username field is empty")
            return
        }
        enableUIControls(false)
        PwnedClient.requestAccountBreaches(usernameTextField.text!) { (breaches, errorMessage) in
            self.enableUIControls(true)
            if let error = errorMessage {
                Helpers.showSimpleAlert(viewController: self, title: "Error", message: error)
            }
            else {
                if breaches?.count == 0 {
                    Helpers.showSimpleAlert(viewController: self, title: "Nice!",
                                            message: "We didn't find any data breach for that account.")
                }
                else {
                    self.breaches = breaches
                    self.performSegue(withIdentifier: self.breachesResultVCSegueID, sender: self)
                }
            }
        }
    }
    
    func enableUIControls(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.usernameTextField.isEnabled = enabled
            self.checkButton.isEnabled = enabled
            enabled ? self.activityIndicator.stopAnimating() : self.activityIndicator.startAnimating()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == breachesResultVCSegueID {
            let vc = segue.destination as! AccountBreachResultVC
            vc.breaches = breaches
            vc.username = usernameTextField.text
        }
    }

}

extension AccountBreachVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
