//
//  Sequence+GetSum.swift
//  ECleaner
//
//  Created by alekseii sorochan on 07.10.2021.
//

import Foundation

extension Sequence  {
    func sum<T: AdditiveArithmetic>(_ predicate: (Element) -> T) -> T { reduce(.zero) { $0 + predicate($1) } }
}

extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}
