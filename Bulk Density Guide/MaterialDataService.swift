//
//  FetchService.swift
//  Bulk Density Guide
//
//  Created by Sean Patterson on 11/8/23.
//  Copyright © 2023 Bosson Design. All rights reserved.
//

import Foundation

class FetchService {
    func fetchMaterialData(from urlString: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "MaterialServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(nil, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                let statusCodeError = NSError(domain: "MaterialServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data, HTTP status code not OK."])
                completion(nil, statusCodeError)
                return
            }
            
            if let error = error {
                completion(nil, error)
            } else {
                completion(data, nil)
            }
        }
        
        task.resume()
    }
}
