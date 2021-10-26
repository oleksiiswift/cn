//
//  String+Numeric.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import Foundation

extension String {
    
    func removeNonNumeric() -> String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

extension String {
    
    func containsNumbers() -> Bool {
        let numberRegEx  = ".*[0-9]+.*"
        let testCase     = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return testCase.evaluate(with: self)
    }
    
    func containsAlphaNumeric() -> Bool {
        let alphaNumericRegEx = ".*[^A-Za-z0-9].*"
        let predicateCase = NSPredicate(format:"SELF MATCHES %@", alphaNumericRegEx)
        return predicateCase.evaluate(with: self)
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
