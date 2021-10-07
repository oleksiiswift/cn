//
//  CGfloat+RemoveDecimals.swift
//  ECleaner
//
//  Created by alekseii sorochan on 07.10.2021.
//

import UIKit

extension CGFloat{
     var cleanValue: String{
         //return String(format: 1 == floor(self) ? "%.0f" : "%.2f", self)
         return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)//
     }
 }
