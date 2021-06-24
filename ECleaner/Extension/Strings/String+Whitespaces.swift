//
//  String+Whitespaces.swift
//  ECleaner
//
//  Created by alekseii sorochan on 24.06.2021.
//

import Foundation

extension String {
    
   func replace(string:String, replacement:String) -> String {
       return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
   }

   func removeWhitespace() -> String {
       return self.replace(string: " ", replacement: "")
   }
 }
