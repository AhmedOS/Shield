//
//  VirustotalClient.swift
//  Shield
//
//  Created by Ahmed Osama on 12/2/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class VirustotalClient {
    
    private init() { }
    
    fileprivate static let apiKey = "c370d97832b586527b8431300ae80da9eb534b5472341c84b5ab0ce9b136dc95"
    
    enum EndPoints {
        static let scanFile = URL(string: "https://www.virustotal.com/vtapi/v2/file/scan")!
        static let fileScanReport = URL(string: "https://www.virustotal.com/vtapi/v2/file/report")!
    }
    
    enum ScanResult: String {
        case queued = "File has been successfully queued for scanning"
        case apiLimitExceeded = "Try again later"
        case unknown = "Unexpected error occurred"
        case unexpectedResponse = "Server sent unexpected response"
    }
    
    enum ReportState: String {
        case scanned
        case queued = "The requested file is still queued for analysis"
        case doesNotPresent = "The requested file doesn't present in the dataset"
        case apiLimitExceeded = "Try again later"
        case unknown = "Unexpected error occurred"
        case unexpectedResponse = "Server sent unexpected response"
    }
    
    static func scan(fileURL: URL, completionHandler: @escaping ((ScanResult) -> Void)) {
        
        let parameters = [
            "apikey": VirustotalClient.apiKey
        ]
        
        let multipartClosure: (MultipartFormData) -> Void = { multipartFormData in
            multipartFormData.append(fileURL, withName: "file")
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: .utf8))!, withName: key)
            }
        }
        
        let encodingCompletionClosure: (SessionManager.MultipartFormDataEncodingResult) -> Void = {
            encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard response.error == nil else {
                        completionHandler(.unknown)
                        return
                    }
                    let status = response.response?.statusCode
                    guard status == 200 else {
                        if status == 204 {
                            completionHandler(.apiLimitExceeded)
                        }
                        else {
                            completionHandler(.unknown)
                        }
                        return
                    }
                    do {
                        let json = try JSON(data: response.data!)
                        let code = json["response_code"].int!
                        if code == 1 {
                            let sha256 = json["sha256"].string!
                            let time = Date().timeIntervalSince1970
                            
                            let file = ScannedFile(context: ModelManager.shared().viewContext)
                            file.name = fileURL.lastPathComponent
                            file.sha256 = sha256
                            file.time = time
                            ModelManager.shared().saveContext()
                            
                            completionHandler(.queued)
                        }
                        else {
                            completionHandler(.unknown)
                        }
                    }
                    catch {
                        completionHandler(.unexpectedResponse)
                    }
                }
            case .failure(let encodingError):
                completionHandler(.unknown)
            }
        }
        
        Alamofire.upload(multipartFormData: multipartClosure,
                         to: VirustotalClient.EndPoints.scanFile,
                         encodingCompletion: encodingCompletionClosure)
        
    }
    
    static func getFileScanReport(for sha256: String, completionHandler: @escaping (ReportState) -> Void) {
        let parameters: Parameters = [
            "apikey": VirustotalClient.apiKey,
            "resource" : sha256
        ]
        
        Alamofire.request(VirustotalClient.EndPoints.fileScanReport, method: .post, parameters: parameters).responseJSON { (response) in
            guard response.error == nil else {
                completionHandler(.unknown)
                return
            }
            let status = response.response?.statusCode
            guard status == 200 else {
                if status == 204 {
                    completionHandler(.apiLimitExceeded)
                }
                else {
                    completionHandler(.unknown)
                }
                return
            }
            do {
                let json = try JSON(data: response.data!)
                let code = json["response_code"].int!
                if code == 1 {
                    let scanReport = FileScanReport(context: ModelManager.shared().viewContext)
                    scanReport.sha256 = sha256
                    scanReport.total = json["total"].int32!
                    scanReport.positives = json["positives"].int32!
                    let scans = json["scans"]
                    for item in scans {
                        let scanResult = AntivirusScanResult(context: ModelManager.shared().viewContext)
                        scanResult.name = item.0
                        scanResult.detected = item.1["detected"].bool!
                        scanResult.result = scanResult.detected ? item.1["result"].string! : ""
                        scanReport.addToScans(scanResult)
                    }
                    ModelManager.shared().saveContext()
                    completionHandler(.scanned)
                }
                else if code == 0 {
                    completionHandler(.doesNotPresent)
                }
                else if code == -2 {
                    completionHandler(.queued)
                }
                else {
                    completionHandler(.unknown)
                }
            }
            catch {
                completionHandler(.unexpectedResponse)
            }
        }
        
    }
    
}
