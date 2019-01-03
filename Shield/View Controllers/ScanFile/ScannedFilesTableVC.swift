//
//  ScannedFilesTableVC.swift
//  Shield
//
//  Created by Ahmed Osama on 12/7/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class ScannedFilesTableVC: UITableViewController {
    
    var scannedFiles: [ScannedFile]!
    
    let scanReportSegueID = "showScanReport"
    var selectedScannedFile: ScannedFile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedScannedFile = nil
        scannedFiles = ModelManager.shared().getAllObjects(for: ScannedFile.self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = scannedFiles.count
        if rows == 0 {
            tableView.setEmptyMessage("No Scanned Files")
        }
        else {
            tableView.restore()
        }
        return rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = scannedFiles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FancyCell", for: indexPath)
        cell.textLabel?.text = file.name
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        cell.detailTextLabel?.text = formatter.string(from: Date(timeIntervalSince1970: file.time))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedScannedFile = scannedFiles[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: scanReportSegueID, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == scanReportSegueID {
            let vc = segue.destination as! ScanReportVC
            vc.scannedFile = selectedScannedFile
        }
    }

}

