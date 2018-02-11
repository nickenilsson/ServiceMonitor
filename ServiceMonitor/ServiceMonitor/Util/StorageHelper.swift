//
//  StorageHelper.swift
//  URLChecker
//
//  Created by Niklas Nilsson on 2018-01-31.
//  Copyright © 2018 Niklas Nilsson. All rights reserved.
//

import Foundation

class StorageHelper {
    
    enum Directory {
        case cache
        case documents
    }
    
    static func getUrl(forDirectory directory: Directory, fileName: String) -> URL {
        switch directory {
        case .documents:    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        case .cache:        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        }
    }
    
    static func store<T: Encodable> (object: T, directory: Directory, fileName: String) {
        let url = getUrl(forDirectory: directory, fileName: fileName)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            let data = try JSONEncoder().encode(object)
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        }catch let error {
            print("Could not save object: \(error.localizedDescription)")
        }
        
    }
    
    static func get<T: Decodable>(directory: Directory, fileName: String) -> T? {
        guard let data = FileManager.default.contents(atPath: getUrl(forDirectory: directory, fileName: fileName).path) else { return nil }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error  {
            print("error: \(error.localizedDescription)")
        }
        return nil
    }
    
    
}

