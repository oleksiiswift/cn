//
//  Cisua.swift
//  cisua
//
//  Created by admin on 21/02/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation
import StoreKit

public class Cisua {
    
    public enum AlertType {
        case notifications
        case tracking
        case cisua
    }
    
    public typealias OurAppsCompletion = (_ apps: [OurAppModel]) -> ()
    
    public typealias ResultCompletion = () -> ()
    public typealias BoolResultCompletion = (Bool) -> ()
    public typealias BoolReturnCompletion = () -> (Bool)
    
    
    internal var isProVersion = false
    
    public static let reachability = Reachability()
    
    internal static let shared = Cisua()
    
    fileprivate static var getOurAppCompletionHandler: OurAppsCompletion? = nil
    
    fileprivate var requestedUpdateState = false
    
    private init() {
        let _ = AppsFlayerManager.shared
        let _ = NotificationsManager.shared
        
        try? Cisua.reachability?.startNotifier()
        
    }
    
}

//extension Cisua {
//    public class func rateUs() {
//        RateUsManager.shared.show()
//    }
//}

extension Cisua {
    
    public class func showPendingAlert(type: Cisua.AlertType! = .cisua, alertShowed: BoolResultCompletion? = nil) {
        switch type {
            case .cisua:            Cisua.shared.showLaunchAlert(alertShowed: alertShowed)
            case .notifications:    NotificationsManager.shared.tryToRegisterAppForRemoteNotifications(alertShowed: alertShowed)
            case .tracking:         AppsFlayerManager.shared.requestTrackingAuthorization(alertShowed: alertShowed)
            case .none:             alertShowed?(false)
        }
    }
    
    public class func initialize() {
        Cisua.shared.checkIfAppShouldBeUpdatedFromServer()
    }
    
    public class func setIsPro(_ isProVersion: Bool) {
        Cisua.shared.isProVersion = isProVersion
    }
    
}

extension Cisua {
    
    public class func getOurApps(completionHandler: OurAppsCompletion? = nil) {
        if Cisua.reachability?.connection == Optional.none {
            completionHandler?([])
            return()
        }
        self.getOurAppCompletionHandler = completionHandler
        if Cisua.shared.requestedUpdateState != true {
            Similar.getOur { (apps) in
                DispatchQueue.main.async {
                    completionHandler?(apps ?? [])
                }
            }
        }
    }
    
}

extension Cisua {
    
    public class func registerEmail(_ email: String, name: String? = nil) {
        Emails.register(email: email)
    }
    
}

extension Cisua {
    
    fileprivate func showLaunchAlert(alertShowed: BoolResultCompletion? = nil) {
        
        if Cisua.reachability?.connection == Optional.none || Cisua.shared.isProVersion == true {
            alertShowed?(false)
            return()
        }
        
        if Bundle.mainBundle.bundleIdentifier != nil && self.requestedUpdateState != true {
            Boost.getBoost { (boost) in
                if let boost = boost {
                    if UserDefaults.standard.bool(forKey: "opened_boost_\(boost.url)") == false &&
                        UserDefaults.standard.bool(forKey: "cancelled_boost_\(boost.url)") == false {
                        alertShowed?(true)
                        Boost.showed(companyId: boost.companyId)
                        AlertsManager.show(
                            title: (boost.title.count > 0 ? boost.title : nil),
                            message: (boost.message.count > 0 ? boost.message : nil),
                            action: (boost.action.count > 0 ? boost.action : nil)
                        ) { (cancelled) in
                            if cancelled == false {
                                Boost.redirected(companyId: boost.companyId) {
                                    UserDefaults.standard.set(true, forKey: "opened_boost_\(boost.url)")
                                    UserDefaults.standard.synchronize()
                                    Cisua.openUrl(url: boost.url)
                                }
                            } else {
                                UserDefaults.standard.set(true, forKey: "cancelled_boost_\(boost.url)")
                                UserDefaults.standard.synchronize()
                            }
                        }
                        return()
                    }
                    
                    if UserDefaults.standard.bool(forKey: "cancelled_boost_\(boost.url)") == true {
                        UserDefaults.standard.set(false, forKey: "cancelled_boost_\(boost.url)")
                        UserDefaults.standard.synchronize()
                    }
                }
                
                
                var paidApp: AppModel?
                var similarApps: [AppModel]?
                
                let group = DispatchGroup()
                
                group.enter()
                Similar.getPaid { (app) in
                    paidApp = app
                    group.leave()
                }
                
                group.enter()
                Similar.getSimilar { (similar) in
                    similarApps = similar
                    group.leave()
                }
                
                group.notify(queue: DispatchQueue.global(qos: .background)) {
                    var appsToShow = [AppModel]()
                    if paidApp != nil {
                        appsToShow.append(paidApp!)
                    }
                    if similarApps != nil {
                        appsToShow.append(contentsOf: similarApps!)
                    }
                    var showApp: AppModel? = nil
                    for idx in 0..<appsToShow.count {
                        let app = appsToShow[idx]
                        if UserDefaults.standard.bool(forKey: "opened_app_\(app.url)") == false &&
                            UserDefaults.standard.bool(forKey: "showed_app_\(app.url)") == false {
                            showApp = app
                            break
                        }
                    }
                    if showApp == nil {
                        for idx in 0..<appsToShow.count {
                            let app = appsToShow[idx]
                            UserDefaults.standard.set(false, forKey: "showed_app_\(app.url)")
                        }
                        UserDefaults.standard.synchronize()
                        if paidApp != nil, UserDefaults.standard.bool(forKey: "opened_app_\(paidApp!.url)") == false {
                            showApp = paidApp
                        }
                    }
                    
                    if let boost = showApp {
                        UserDefaults.standard.set(true, forKey: "showed_app_\(boost.url)")
                        UserDefaults.standard.synchronize()
                        alertShowed?(true)
                        AlertsManager.show(title: boost.title, message: boost.message, action: boost.action) { (cancelled) in
                            if cancelled == false {
                                UserDefaults.standard.set(true, forKey: "opened_app_\(boost.url)")
                                UserDefaults.standard.synchronize()
                                Cisua.openUrl(url: boost.url)
                            }
                        }
                    } else if let boost = boost {
                        if UserDefaults.standard.bool(forKey: "opened_boost_\(boost.url)") == false &&
                            UserDefaults.standard.bool(forKey: "cancelled_boost_\(boost.url)") == false {
                            alertShowed?(true)
                            Boost.showed(companyId: boost.companyId)
                            AlertsManager.show(title: boost.title, message: boost.message, action: boost.action) { (cancelled) in
                                if cancelled == false {
                                    Boost.redirected(companyId: boost.companyId) {
                                        UserDefaults.standard.set(true, forKey: "opened_boost_\(boost.url)")
                                        UserDefaults.standard.synchronize()
                                        Cisua.openUrl(url: boost.url)
                                    }
                                } else {
                                    UserDefaults.standard.set(true, forKey: "cancelled_boost_\(boost.url)")
                                    UserDefaults.standard.synchronize()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}

extension Cisua {
    
    fileprivate func checkIfAppShouldBeUpdatedFromServer() {
        if Cisua.reachability?.connection == Optional.none {
            return()
        }
        if self.requestedUpdateState { return }
        self.requestedUpdateState = true
        if Bundle.mainBundle.bundleIdentifier != nil {
            
            if UserDefaults.standard.string(forKey: "updated") == nil {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd hh:mm:ss"
                let updated = df.string(from: Date(timeIntervalSince1970: 0))
                UserDefaults.standard.set(updated, forKey: "updated")
                UserDefaults.standard.synchronize()
            }
            
            if let url = URL(string: "\(Api.Similar.updated)?bundle=\(Bundle.mainBundle.bundleIdentifier!)&updated=\(UserDefaults.standard.string(forKey: "updated")!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
                request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
                let task = URLSession.shared.dataTask(with: request) { [unowned self] (data, _, _) in
                    do {
                        if let data = data {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                            if let enabled = json?["enabled"] as? Bool {
                                UserDefaults.standard.set(enabled, forKey: "enabled")
                                if let updated = json?["updated"] as? String {
                                    UserDefaults.standard.set(nil, forKey: "paid")
                                    UserDefaults.standard.set(nil, forKey: "similar")
                                    UserDefaults.standard.set(nil, forKey: "our")
                                    UserDefaults.standard.set(updated, forKey: "updated")
                                }
                                UserDefaults.standard.synchronize()
                            }
                        }
                    } catch {}
                    
                    self.requestedUpdateState = false
                    
                    if Cisua.getOurAppCompletionHandler != nil {
                        Cisua.getOurApps(completionHandler: Cisua.getOurAppCompletionHandler)
                    }
                    
                }
                task.resume()
            }
        }
    }
    
}

extension Cisua {
    
    internal class func openUrl(url: String) {
        DispatchQueue.main.async {
            if let url = URL(string: url) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    components?.scheme = "http"
                    if let url = components?.url, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
}

extension Cisua {
    
    public class func trackPurchase(product: SKProduct) {
        AppsFlayerManager.shared.trackPurchase(product: product)
    }
    
    public class func trackSubscription(product: SKProduct, isTrial: Bool, expirationDate: Date) {
        AppsFlayerManager.shared.trackSubscription(product: product, isTrial: isTrial, expirationDate: expirationDate)
    }
    
}
