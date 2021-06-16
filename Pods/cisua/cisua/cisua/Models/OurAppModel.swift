//
//  AppModel.swift
//  cisua
//
//  Created by admin on 22/02/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

public struct OurAppModel: AppModel, AppModelCustomInit {
    public let title: String
    public let message: String
    public let action: String
    public let url: String
    public var banner: String
    public var icon: String
    
    init(title: String, message: String, action: String, url: String) {
        self.title = title
        self.message = message
        self.action = action
        self.url = url
        self.icon = ""
        self.banner = ""
    }
    
    init(title: String, message: String, action: String, url: String, banner: String) {
        self.init(title: title, message: message, action: action, url: url)
        self.banner = banner
    }
    
    internal mutating func set(icon: String) {
        self.icon = icon
    }
    
    internal init?(dictionary: [String: String]) {
        guard let title = dictionary["title"],
            let message = dictionary["message"],
            let action = dictionary["action"],
            let url = dictionary["url"],
            let icon = dictionary["icon"],
            let banner = dictionary["banner"]
            else { return nil }
        self.init(title: title, message: message, action: action, url: url)
        self.icon = icon
        self.banner = banner
    }
    
    internal func dictionaryRepresentation() -> [String: String] {
        return ["title": title, "message": message, "action": action, "url": url, "banner": banner, "icon": icon]
    }
}
