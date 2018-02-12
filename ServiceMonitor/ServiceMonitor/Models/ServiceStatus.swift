//
//  ServiceStatus.swift
//  ServiceMonitor
//
//  Created by Niklas Nilsson on 2018-02-11.
//  Copyright © 2018 Niklas Nilsson. All rights reserved.
//

import Foundation

struct ServiceStatus: Codable {
    
    static let archivePath = "sites"
    let name: String
    let url: URL
    var statusCode: Int?
    var lastChecked: Date? = nil
    var statusDescription: String? {
        if let statusCode = statusCode {
            return (200...299).contains(statusCode) ? "UP" : "FAIL"
        }
        if lastChecked != nil && statusCode == nil { return "FAIL" }
        return nil
    }
    
    init(name: String, url: URL, statusCode: Int? = nil, lastChecked: Date? = nil){
        self.name = name
        self.url = url
        self.statusCode = statusCode
        self.lastChecked = lastChecked
    }
}
