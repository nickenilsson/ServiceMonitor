//
//  UrlPinger.swift
//  URLChecker
//
//  Created by Niklas Nilsson on 2018-01-25.
//  Copyright © 2018 Niklas Nilsson. All rights reserved.
//

import Foundation

class URLPinger {
    
    let session: URLSession
    
    static let shared: URLPinger = {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        return URLPinger(session: session)
    }()
    
    private init(session: URLSession) {
        self.session = session
    }
    
    func checkUrl(url: URL, completion: @escaping(_ statusCode: Int?) -> ())  {
        session.dataTask(with: url, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode)
            }else {
                completion(nil)
            }
        }).resume()
    }
    
}

