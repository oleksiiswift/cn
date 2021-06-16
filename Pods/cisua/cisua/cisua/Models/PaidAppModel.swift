//
//  PaidModel.swift
//  cisua
//
//  Created by admin on 01/03/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

internal struct PaidAppModel: AppModel, AppModelCustomInit {
    let title: String
    let message: String
    let action: String
    let url: String
    
    init(title: String, message: String, action: String, url: String) {
        self.title = title
        self.message = message
        self.action = action
        self.url = url
    }
    
    init?(dictionary: [String: String]) {
        guard let title = dictionary["title"],
            let message = dictionary["message"],
            let action = dictionary["action"],
            let url = dictionary["url"]
            else { return nil }
        self.init(title: title, message: message, action: action, url: url)
    }
    
    func dictionaryRepresentation() -> [String: String] {
        return ["title": title, "message": message, "action": action, "url": url]
    }
}
