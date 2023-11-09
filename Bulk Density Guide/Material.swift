//
//  Material.swift
//  Bulk Density Guide
//
//  Created by Sean Patterson on 11/8/23.
//  Copyright © 2023 Bosson Design. All rights reserved.
//

import Foundation

struct Material: Codable {
    let name: String
    let densityLbFt3: Double
    let densityGmCm3: Double?
}
