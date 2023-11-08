//
//  FetchService.swift
//  Bulk Density Guide
//
//  Created by Sean Patterson on 11/8/23.
//  Copyright © 2023 Bosson Design. All rights reserved.
//

import Foundation

class MaterialDataService {
    func fetchMaterialData(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "MaterialDataServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "MaterialDataServiceError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
            } else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.failure(NSError(domain: "MaterialDataServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected HTTP status code: \(statusCode)"])))
            }
        }.resume()
    }
}
