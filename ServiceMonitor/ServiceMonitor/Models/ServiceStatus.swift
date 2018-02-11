//
//  ServiceStatus.swift
//  ServiceMonitor
//
//  Created by Niklas Nilsson on 2018-02-11.
//  Copyright © 2018 Niklas Nilsson. All rights reserved.
//

import Foundation

struct ServiceStatus: Codable {
    
    var statusCode: Int?
    let url: URL
    var lastChecked: Date? = nil
    static let archivePath = "sites"
    var statusDescription: String? {
        if let statusCode = statusCode {
            return (200...299).contains(statusCode) ? "UP" : "DOWN"
        }
        if lastChecked != nil && statusCode == nil { return "DOWN" }
        return nil
    }
    
    init(statusCode: Int?, url: URL, lastChecked: Date? = nil){
        self.statusCode = statusCode
        self.url = url
        self.lastChecked = lastChecked
    }
}
