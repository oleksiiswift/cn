//
//  FileFormats.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.11.2021.
//

import Foundation

enum ExportContactsAvailibleFormat {
    case vcf
    case csv
    case none
    
    var formatRowValue: String {
        switch self {
            case .vcf:
                return "VCF"
            case .csv:
                return "CSV"
            default:
                return "hello chao"
        }
    }
}
