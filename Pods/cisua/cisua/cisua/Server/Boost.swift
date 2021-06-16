//
//  Boost.swift
//  cisua
//
//  Created by admin on 28/02/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

internal class Boost {
    
    internal typealias BoostCompletion = (_ boost: BoostModel?) -> ()
    
    internal class func getBoost(completionHandler: BoostCompletion? = nil) {
        if UserDefaults.standard.bool(forKey: "enabled") == false {
            completionHandler?(nil)
            return
        }
        if let url = URL(string: "\(Api.Boost.request)?bundle=\(Bundle.mainBundle.bundleIdentifier!)&lang=\(Api.lang)") {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
            let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
                do {
                    if let data = data {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                        if json?.count != 0 {
                            
                            var url = ""
                            
                            if let val = json?["promote_app_id"] as? String, val.count > 0 {
                                url = "itms-apps://itunes.apple.com/app/id\(val)"
                            } else if let val = json?["search_term"] as? String, val.count > 0 {
                                url = "itms-apps://search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?media=software&term=\(val)"
                            } else if let val = json?["url"] as? String, val.count > 0 {
                                url = val
                            }
                            
                            completionHandler?(
                                BoostModel(
                                    title: (json?["alert_title"] as? String) ?? "",
                                    message: (json?["alert_message"] as? String) ?? "",
                                    action: (json?["alert_action"] as? String) ?? "",
                                    url: url,
                                    companyId: (json?["id"] as? String) ?? ""
                                )
                            )
                            
                            return()
                        }
                    }
                } catch {}
                completionHandler?(nil)
            }
            task.resume()
        }
    }
    
    internal class func showed(companyId: String, completion: (()->())? = nil) {
        if let url = URL(string: "\(Api.Boost.showed)?company=\(companyId)&bundle=\(Bundle.mainBundle.bundleIdentifier!)&lang=\(Api.lang)") {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request) { (_, _, _) in
                completion?()
            }
            task.resume()
        }
    }
    
    internal class func redirected(companyId: String, completion: (()->())? = nil) {
        if let url = URL(string: "\(Api.Boost.redirected)?company=\(companyId)&bundle=\(Bundle.mainBundle.bundleIdentifier!)&lang=\(Api.lang)") {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request) { (_, _, _) in
                completion?()
            }
            task.resume()
        }
    }
}
