//
//  Array+BestValue.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.11.2021.
//

import Foundation

extension Array where Element == String {

    var bestElement: String? {
        var options: [String : Int] = [:]

        for element in self {
            if let result = options[element] {
                options[element] = result + 1
            } else {
                options[element] = 1
            }
        }

        return options.sorted { $0.1 > $1.1 }.first?.key
    }
}
