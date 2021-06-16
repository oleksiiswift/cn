//
//  Push.swift
//  cisua
//
//  Created by admin on 01/03/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

internal class Push {
    
    internal class func register(token: String) {
        
        let now = Date()
        let lastRegisterDate = (UserDefaults.standard.object(forKey: "lastRegisteredTokenDate") as? Date) ?? Date.distantPast
        let minutes = Calendar.current.dateComponents([.minute], from: now, to: lastRegisterDate).minute ?? 0
        
        if abs(minutes) > 2 {
            if let url = URL(string: "\(Api.PushNotifications.register)?bundle=\(Bundle.mainBundle.bundleIdentifier!)") {
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 90)
                request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
                request.httpMethod = "POST"
                request.httpBody = "token=\(token)".data(using: .utf8)
                URLSession.shared.dataTask(with: request).resume()
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(now, forKey: "lastRegisteredTokenDate")
                UserDefaults.standard.synchronize()
            }
        }
        
    }
    
    internal class func opened(companyId: String, completion: (()->())? = nil) {
        if let url = URL(string: "\(Api.PushNotifications.opened)?company=\(companyId)&bundle=\(Bundle.mainBundle.bundleIdentifier!)") {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
            request.httpMethod = "POST"
            request.httpBody = "token=\(UserDefaults.standard.string(forKey: "token")!)".data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { (_, _, _) in
                completion?()
            }
            task.resume()
        }
    }
    
    internal class func redirected(companyId: String, completion: (()->())? = nil) {
        if let url = URL(string: "\(Api.PushNotifications.redirected)?company=\(companyId)&bundle=\(Bundle.mainBundle.bundleIdentifier!)") {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
            request.httpMethod = "POST"
            request.httpBody = "token=\(UserDefaults.standard.string(forKey: "token")!)".data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { (_, _, _) in
                completion?()
            }
            task.resume()
        }
    }
}
