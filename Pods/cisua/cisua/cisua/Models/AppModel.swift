//
//  AppModel.swift
//  cisua
//
//  Created by admin on 01/03/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

public protocol AppModel {
    var title: String {get}
    var message: String {get}
    var action: String {get}
    var url: String {get}
}

protocol AppModelCustomInit {
    init?(dictionary: [String: String])
    func dictionaryRepresentation() -> [String: String]
}
