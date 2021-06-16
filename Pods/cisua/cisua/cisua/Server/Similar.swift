//
//  Similar.swift
//  cisua
//
//  Created by admin on 28/02/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation

internal class Similar {
    
    internal typealias SimilarAppsCompletion = (_ apps: [SimilarAppModel]?) -> ()
    internal typealias OurAppsCompletion = (_ apps: [OurAppModel]?) -> ()
    internal typealias PaidAppCompletion = (_ app: PaidAppModel?) -> ()
    
    internal class func getPaid(completionHandler: PaidAppCompletion? = nil) {
        if UserDefaults.standard.bool(forKey: "enabled") == false {
            completionHandler?(nil)
            return
        }
        if UserDefaults.standard.object(forKey: "paid") == nil {
            if let url = URL(string: "\(Api.Similar.paid)?bundle=\(Bundle.mainBundle.bundleIdentifier!)&lang=\(Api.lang)") {
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
                request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
                let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
                    do {
                        if let data = data {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                            if json?.count != 0 {
                                
                                let model = PaidAppModel(
                                    title: (json?["title"] as? String) ?? "",
                                    message: (json?["message"] as? String) ?? "",
                                    action: (json?["action"] as? String) ?? "",
                                    url: "itms-apps://itunes.apple.com/app/id\((json?["app_id"] as? String) ?? "")"
                                )
                                
                                UserDefaults.standard.set(model.dictionaryRepresentation(), forKey: "paid")
                                UserDefaults.standard.synchronize()
                                
                                completionHandler?(model)
                                return()
                            }
                        }
                    } catch {}
                    completionHandler?(nil)
                }
                task.resume()
            }
        } else {
            if let app = UserDefaults.standard.object(forKey: "paid") as? [String:String] {
                let app = PaidAppModel(dictionary: app)
                completionHandler?(app)
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    internal class func getSimilar(completionHandler: SimilarAppsCompletion? = nil) {
        if UserDefaults.standard.bool(forKey: "enabled") == false {
            completionHandler?(nil)
            return
        }
        if UserDefaults.standard.object(forKey: "similar") == nil {
            if let url = URL(string: "\(Api.Similar.similar)?bundle=\(Bundle.mainBundle.bundleIdentifier!)&lang=\(Api.lang)") {
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
                request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
                let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
                    do {
                        if let data = data {
                            var apps = [SimilarAppModel]()
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]]
                            
                            json?.forEach {
                                apps.append(
                                    SimilarAppModel(
                                        title: ($0["title"] as? String) ?? "",
                                        message: ($0["message"] as? String) ?? "",
                                        action: ($0["action"] as? String) ?? "",
                                        url: "itms-apps://itunes.apple.com/app/id\(($0["app_id"] as? String) ?? "")"
                                    )
                                )
                            }
                            
                            let mappedArray = apps.map { $0.dictionaryRepresentation() }
                            UserDefaults.standard.set(mappedArray, forKey: "similar")
                            UserDefaults.standard.synchronize()
                            
                            completionHandler?(apps)
                            return()
                        }
                    } catch {}
                    completionHandler?(nil)
                }
                task.resume()
            }
        } else {
            if let apps = UserDefaults.standard.object(forKey: "similar") as? [[String: String]] {
                let mappedArray = apps.compactMap { SimilarAppModel(dictionary: $0) }
                completionHandler?(mappedArray)
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    internal class func getOur(completionHandler: OurAppsCompletion? = nil) {
        if UserDefaults.standard.object(forKey: "our") == nil {
            if let url = URL(string: "\(Api.Similar.our)?bundle=\(Bundle.mainBundle.bundleIdentifier!)&lang=\(Api.lang)") {
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
                request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
                let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
                    do {
                        if let data = data {
                            
                            let group = DispatchGroup()
                            
                            var apps = [OurAppModel]()
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]]
                            json?.forEach {
                                
                                let appId = ($0["app_id"] as? String) ?? ""
                                
                                let model = OurAppModel(
                                    title: ($0["title"] as? String) ?? "",
                                    message: ($0["message"] as? String) ?? "",
                                    action: ($0["action"] as? String) ?? "",
                                    url: "itms-apps://itunes.apple.com/app/id\(appId)",
                                    banner: Api.Similar.imagePath + (($0["banner_path"] as? String) ?? "")
                                )
                                apps.append(model)
                                
                                group.enter()
                                
                                self.iterateThroughAvailableCountries(id: appId) { [url = model.url] (icon) in
                                    
                                    for idx in 0..<apps.count {
                                        if apps[idx].url == url {
                                            if icon.count > 0 { apps[idx].icon = icon }
                                            else { apps.remove(at: idx) }
                                            break
                                        }
                                    }
                                    
                                    group.leave()
                                    
                                }
                                
                            }
                            
                            group.notify(queue: .main) {
                                let mappedArray = apps.map { $0.dictionaryRepresentation() }
                                UserDefaults.standard.set(mappedArray, forKey: "our")
                                UserDefaults.standard.synchronize()
                                completionHandler?(apps)
                            }
                            return()
                        }
                    } catch {}
                    completionHandler?(nil)
                }
                task.resume()
            }
        } else {
            if let apps = UserDefaults.standard.object(forKey: "our") as? [[String: String]] {
                let mappedArray = apps.compactMap { OurAppModel(dictionary: $0) }
                completionHandler?(mappedArray)
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    internal class func iterateThroughAvailableCountries(id: String, countries: [String] = ["us", "ru", "gb", "ch", "sg", "au", "se", "ca", "mx", "cn", "nl", "tr", "br", "es", "be", "at", "de", "fr", "jp", "kr", "nz", "ie", "ae", "hu", "cl", "ro", "cz", "il", "ua", "kw", "co", "gr", "la", "sa", "id", "th", "hk", "dk", "no", "fi", "in", "pt", "it", "tw", "vn", "za", "my", "ph", "kz"], completion: ((String) -> ())? = nil) {
        var newCountries = countries
        if newCountries.count > 0 {
            let country = newCountries.removeFirst()
            self.checkForAppIcon(id: id, country: country) {
                if ($0 != nil), $0!.count > 0 {
                    completion?($0!)
                } else {
                    self.iterateThroughAvailableCountries(id: id, countries: newCountries, completion: completion)
                }
            }
        } else {
            completion?("")
        }
    }
    
    internal class func checkForAppIcon(id: String, country: String, completion: ((String?) -> ())? = nil) {
        if let url = URL(string: "https://itunes.apple.com/lookup?id=\(id)&country=\(country)") {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
            let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
                do {
                    if let data = data {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                        if let first = (json?["results"] as? [[String: Any]])?.first {
                            if let artwork = first["artworkUrl100"] as? String {
                                completion?(artwork)
                                return
                            }
                        }
                    }
                }
                catch {}
                completion?(nil)
            }
            task.resume()
        }
    }
    
}
