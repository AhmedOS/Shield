//
//  Breach.swift
//  Shield
//
//  Created by Ahmed Osama on 12/16/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation

struct Breach: Codable {
    
    let title: String!
    let domain: String!
    let breachDate: String!
    let description: String!
    let dataClasses: [String]!
    let logoPath: String!
    
    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case domain = "Domain"
        case breachDate = "BreachDate"
        case description = "Description"
        case dataClasses = "DataClasses"
        case logoPath = "LogoPath"
    }
    
}
