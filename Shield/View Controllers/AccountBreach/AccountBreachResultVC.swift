//
//  AccountBreachResultVC.swift
//  Shield
//
//  Created by Ahmed Osama on 12/17/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import Alamofire

class AccountBreachResultVC: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var breachesTableView: UITableView!
    let breachesTableCellID = "breachesTableCell"
    let breachDetailsVCSegueID = "showBreachDetails"
    var breaches: [Breach]!
    var selectedBreach: Breach!
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        breachesTableView.dataSource = self
        breachesTableView.delegate = self
        usernameLabel.text = username
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedBreach = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == breachDetailsVCSegueID {
            let vc = segue.destination as! AccountBreachDetailsVC
            vc.breach = selectedBreach
        }
    }

}

extension AccountBreachResultVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = breaches.count
        if rows == 0 {
            tableView.setEmptyMessage("No Breaches")
        }
        else {
            tableView.restore()
        }
        return rows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: breachesTableCellID) as! BreachWebsiteTableCell
        let breach = breaches[indexPath.row]
        cell.domain.text = breach.domain
        cell.websiteName.text = breach.title
        cell.imageURL = URL(string: breach.logoPath)!
        let image = Helpers.sharedCache.object(forKey: breach.logoPath! as NSString)
        if image != nil {
            cell.logoImageView?.image = image
        }
        else {
            Alamofire.request(breach.logoPath).responseData { (response) in
                let path = (response.request?.url)!
                guard response.error == nil else {
                    return
                }
                let image = UIImage(data: response.data!)!
                Helpers.sharedCache.setObject(image, forKey: path.absoluteString as NSString)
                guard path == cell.imageURL else {
                    return
                }
                DispatchQueue.main.async {
                    cell.logoImageView?.image = image
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBreach = breaches[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: breachDetailsVCSegueID, sender: self)
    }
}
