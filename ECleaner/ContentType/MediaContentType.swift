//
//  MediaContentType.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit

enum MediaContentType {
    
    case userPhoto
    case userVideo
    case userContacts
    case none
    
    var cellTitle: [Int: [Int : String]] {
        switch self {
            case .userPhoto:
                return [0: [0: "similar",
                            1: "dublicate",
                            2: "screenshots",
                            3: "selfie",
                            4: "face?",
                            5: "live",
                            6: "location"]]
            case .userVideo:
                return [0: [0: "large",
                            1: "duplicate",
                            2: "similart",
                            3: "screen rec",
                            4: "comoress?"]]
            case .userContacts:
                return [0: [0: "all contacts",
                            1: "empty",
                            2: "duplicates"]]
            case .none:
                return [0: [0: ""]]
        }
    }
    
    public func getCellTitle(index: Int) -> String {
        switch self {
            case .userPhoto:
                switch index {
                    case 0:
                        return "simmilar"
                    case 1:
                        return "dublicates"
                    case 2:
                        return "screenshots"
                    case 3:
                        return "selfie"
                    case 4:
                        return "face?"
                    case 5:
                        return "live photos"
                    case 6:
                        return "location"
                    default:
                        return ""
                }
            case .userVideo:
                switch index {
                    case 0:
                        return "large"
                    case 1:
                        return "duplicate"
                    case 2:
                        return "similart"
                    case 3:
                        return "screen rec"
                    case 4:
                        return "comoress?"
                    default:
                        return ""
                }
            case .userContacts:
                switch index {
                    case 0:
                        return "all contacts"
                    case 1:
                        return "empty"
                    case 2:
                        return "duplicates"
                    default:
                        return ""
                }
            case .none:
                return ""
        }
    }
    
    var numberOfSection: Int {
        return 1
    }
    
    var numberOfRows: Int {
        switch self {
            case .userPhoto:
                return 7
            case .userVideo:
                return 5
            case .userContacts:
                return 3
            case .none:
                return 0
        }
    }
}
