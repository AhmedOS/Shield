//
//  PwnedClient.swift
//  Shield
//
//  Created by Ahmed Osama on 12/16/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import Alamofire

class PwnedClient {
    
    private init() { }
    
    enum EndPoint: String {
        func url(suffix: String) -> URL {
            return (URL(string: self.rawValue)!).appendingPathComponent(suffix)
        }
        case account = "https://haveibeenpwned.com/api/v2/breachedaccount/"
        case password = "https://api.pwnedpasswords.com/range/"
    }
    
    static func requestAccountBreaches(_ account: String, completionHandler: @escaping ([Breach]?, String?) -> ()) {
        Alamofire.request(EndPoint.account.url(suffix: account)).responseJSON { (response) in
            guard response.error == nil else {
                completionHandler(nil, response.error?.localizedDescription)
                return
            }
            let status = response.response?.statusCode
            guard status == 200 else {
                completionHandler(nil, "Invalid response code: \(status!)")
                return
            }
            do {
                let decoder = JSONDecoder()
                let breaches = try decoder.decode([Breach].self, from: response.data!)
                completionHandler(breaches, nil)
            }
            catch {
                completionHandler(nil, "Failed to process server response")
            }
        }
    }
    
    static func requestPasswordBreach(_ password: String, completionHandler: @escaping (Int?, String?) -> ()) {
        var sha1 = (SHA1.hexString(from: password)!).replacingOccurrences(of: " ", with: "")
        let hashPrefix = String(sha1.prefix(5))
        sha1.removeFirst(5)
        Alamofire.request(EndPoint.password.url(suffix: hashPrefix)).responseString { (response) in
            guard response.error == nil else {
                completionHandler(nil, response.error?.localizedDescription)
                return
            }
            let status = response.response?.statusCode
            guard status == 200 else {
                completionHandler(nil, "Invalid response code: \(status!)")
                return
            }
            let allHashes = String(bytes: response.data!, encoding: .utf8)
            let hashes = allHashes?.components(separatedBy: .newlines)
            for hash in hashes! {
                let comp = hash.components(separatedBy: ":")
                if comp[0] == sha1 {
                    completionHandler(Int(comp[1]), nil)
                    return
                }
            }
            completionHandler(0, nil)
        }
    }
    
}
