//
//  Email.swift
//  cisua
//
//  Created by admin on 01/03/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation
internal class Emails {
    internal class func register(email: String, name: String? = nil) {
        if email.isValidEmail() {
            if let url = URL(string: Api.Emails.register) {
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 90)
                request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
                request.httpMethod = "POST"
                var body = "email=\(email)"
                if let name = name {
                    body += "&name=\(name)"
                }
                request.httpBody = body.data(using: .utf8)
                URLSession.shared.dataTask(with: request).resume()
            }
        }
    }
}
