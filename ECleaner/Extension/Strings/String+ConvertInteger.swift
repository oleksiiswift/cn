//
//  String+ConvertInteger.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import Foundation

extension String{
    
    func replacingStringAndConvertToIntegerForImage() -> Int {
        if let integer = Int(self.replacingOccurrences(of: "image", with: "")) {
            return integer
        } else {
            return 0
        }
    }
}
