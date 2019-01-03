//
//  ScanReportVC.swift
//  Shield
//
//  Created by Ahmed Osama on 12/12/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class ScanReportVC: UIViewController {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var scanResultLabel: UILabel!
    @IBOutlet weak var scanDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var scannedFile: ScannedFile!
    var scanReport: FileScanReport?
    var scanResults = [AntivirusScanResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        setupUI()
        let sha256 = scannedFile.sha256
        if let sha256 = sha256 {
            scanReport = ModelManager.shared().getFileScanReport(for: sha256)
        }
        if scanReport != nil {
            refreshButton.isEnabled = false
            reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let sha256 = scannedFile.sha256
        if scanReport == nil, let sha256 = sha256 {
            refreshButton.isEnabled = false
            VirustotalClient.getFileScanReport(for: sha256) { (state) in
                DispatchQueue.main.async {
                    self.processReportState(state: state)
                }
            }
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        let sha256 = scannedFile.sha256!
        VirustotalClient.getFileScanReport(for: sha256) { (state) in
            DispatchQueue.main.async {
                self.processReportState(state: state)
            }
        }
    }
    
    func setupUI() {
        fileNameLabel.text = scannedFile.name
        scanResultLabel.text = "Total Detections: 0/0"
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        scanDateLabel.text = formatter.string(from: Date(timeIntervalSince1970: scannedFile.time))
    }
    
    func processReportState(state: VirustotalClient.ReportState) {
        if state != .scanned {
            refreshButton.isEnabled = true
        }
        switch state {
        case .scanned:
            DispatchQueue.main.async {
                self.reloadData()
            }
        case .queued:
            Helpers.showSimpleAlert(viewController: self, title: "In queue", message: state.rawValue)
        case .doesNotPresent:
            Helpers.showSimpleAlert(viewController: self, title: "File doesn't exist", message: state.rawValue)
        case .apiLimitExceeded:
            Helpers.showSimpleAlert(viewController: self, title: "Server busy", message: state.rawValue)
        case .unknown, .unexpectedResponse:
            Helpers.showSimpleAlert(viewController: self, title: "Error", message: state.rawValue)
        }
    }
    
    func reloadData() {
        scanResults = scanReport?.scans?.allObjects as! [AntivirusScanResult]
        DispatchQueue.main.async {
            self.scanResultLabel.text = "Total Detections: " + String((self.scanReport?.positives)!) + "/" + String((self.scanReport?.total)!)
            self.tableView.reloadData()
        }
    }
    
}

extension ScanReportVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = scanResults.count
        if rows == 0 {
            tableView.setEmptyMessage("No Results")
        }
        else {
            tableView.restore()
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FancyCell", for: indexPath)
        let detected = scanResults[indexPath.row].detected
        if detected {
            cell.textLabel?.text = scanResults[indexPath.row].result!
            cell.imageView?.image = #imageLiteral(resourceName: "cancel-24")
        }
        else {
            cell.textLabel?.text = "Not Detected"
            cell.imageView?.image = #imageLiteral(resourceName: "check-mark-24")
        }
        cell.detailTextLabel?.text = scanResults[indexPath.row].name
        return cell
    }
    
}
