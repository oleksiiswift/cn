//
//  AppsFlyerManager.swift
//  cisua
//
//  Created by Anton Litvinov on 28.01.2020.
//

import Foundation
import AppsFlyerLib
import StoreKit

class AppsFlayerManager: NSObject {
    
    internal static let shared = AppsFlayerManager()
    
    private let subscriptionIds = ["1weeksub", "1month", "1year", "45464748", "35363738", "23534342", "435345434", "274368", "274367", "274369", "1_month_premium", "1_week_premium", "monthsubscription", "yearsubscription", "1_year_prem", "3_month_prem", ""]
    private let purchaseIds     = ["full", "remove_ads", "noadspurchase", "removeads", "lifetime_prem", "removeadds"]
    
    private var appId: String? = UserDefaults.standard.string(forKey: "app_id") {
        didSet {
            UserDefaults.standard.set(self.appId, forKey: "app_id")
            UserDefaults.standard.synchronize()
        }
    }
    
    private var shouldTrackAppLaunch: (UIApplication)? = nil
    private var shouldOpenUrl: (UIApplication, URL, [UIApplication.OpenURLOptionsKey: Any]?)? = nil
    private var shouldContineuUserActivity: (UIApplication, NSUserActivity)? = nil
    
    override init() {
        super.init()
        
        AppsFlyerTracker.shared().delegate = self
        AppsFlyerTracker.shared().appsFlyerDevKey = "bKpzhfkT7SDDVPGpGg2RaJ"
        
        AppSwizzle.shared().applicationDidBecomeActiveHandler { (application) in
            if self.appId == nil {
                self.shouldTrackAppLaunch = (application)
            } else {
                AppsFlyerTracker.shared().trackAppLaunch()
            }
        }
        
        AppSwizzle.shared().applicationOpenUrlOptionsHandler { (application, url, options) in
            if self.appId == nil {
                self.shouldOpenUrl = (application, url, options)
            } else {
                AppsFlyerTracker.shared().handleOpen(url, options: options)
            }
        }
        
        AppSwizzle.shared().applicationContinueUserActivityHandler { (application, userActivity) in
            if self.appId == nil {
                self.shouldContineuUserActivity = (application, userActivity)
            } else {
                AppsFlyerTracker.shared().continue(userActivity, restorationHandler: nil)
            }
        }
        
        if self.appId != nil {
            AppsFlyerTracker.shared().appleAppID = self.appId!
        } else {
            self.iterateThroughAvailableCountries(bundle: Bundle.mainBundle.bundleIdentifier!) { (appId) in
                if appId.count > 0 {
                    self.appId = appId
                    AppsFlyerTracker.shared().appleAppID = appId
                    if self.shouldTrackAppLaunch != nil { AppsFlyerTracker.shared().trackAppLaunch() }
                    if self.shouldOpenUrl != nil { AppsFlyerTracker.shared().handleOpen(self.shouldOpenUrl!.1, options: self.shouldOpenUrl!.2) }
                    if self.shouldContineuUserActivity != nil { AppsFlyerTracker.shared().continue(self.shouldContineuUserActivity!.1, restorationHandler: nil) }
                }
                self.shouldTrackAppLaunch = nil
                self.shouldOpenUrl = nil
                self.shouldContineuUserActivity = nil
            }
        }
        
    }
    
    private func iterateThroughAvailableCountries(bundle: String, countries: [String] = ["us", "ru", "gb", "ch", "sg", "au", "se", "ca", "mx", "cn", "nl", "tr", "br", "es", "be", "at", "de", "fr", "jp", "kr", "nz", "ie", "ae", "hu", "cl", "ro", "cz", "il", "ua", "kw", "co", "gr", "la", "sa", "id", "th", "hk", "dk", "no", "fi", "in", "pt", "it", "tw", "vn", "za", "my", "ph", "kz"], completion: ((String) -> ())? = nil) {
        if Cisua.reachability?.connection == Optional.none {
            completion?("")
            return()
        }
        var newCountries = countries
        if newCountries.count > 0 {
            let country = newCountries.removeFirst()
            self.checkForAppId(bundle: bundle, country: country) {
                if ($0 != nil), $0!.count > 0 {
                    completion?($0!)
                } else {
                    self.iterateThroughAvailableCountries(bundle: bundle, countries: newCountries, completion: completion)
                }
            }
        } else {
            completion?("")
        }
    }
    
    private func checkForAppId(bundle: String, country: String, completion: ((String?) -> ())? = nil) {
        if let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundle)&country=\(country)") {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            request.setValue(Api.userAgent, forHTTPHeaderField: "User-Agent")
            let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
                do {
                    if let data = data {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                        if let first = (json?["results"] as? [[String: Any]])?.first {
                            if let appId = first["trackId"] as? String {
                                completion?(appId)
                                return
                            } else if let appId = first["trackId"] as? Int {
                                completion?("\(appId)")
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

extension AppsFlayerManager: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) { }
    func onConversionDataFail(_ error: Error) { }
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) { }
    func onAppOpenAttributionFailure(_ error: Error) { }
}

extension AppsFlayerManager {
    
    public func trackPurchase(product: SKProduct) {
        
        if self.subscriptionIds.contains(product.productIdentifier.lowercased()) ||
            product.productIdentifier.lowercased().contains("subscription") {
            
            if UserDefaults.standard.object(forKey: "initial_date") == nil {
                UserDefaults.standard.set(Date(), forKey: "initial_date")
                UserDefaults.standard.synchronize()
            }
            
            var initialDate = UserDefaults.standard.object(forKey: "initial_date") as! Date
            
            if UserDefaults.standard.bool(forKey: "trial_expired") == false, product.introductoryPrice != nil {
                
                if let p = product.introductoryPrice?.subscriptionPeriod {
                    if p.unit == .day {
                        if let nextDate = Calendar.current.date(byAdding: .day, value: p.numberOfUnits, to: initialDate) {
                            if nextDate.interval(ofComponent: .day, fromDate: initialDate) > p.numberOfUnits {
                                UserDefaults.standard.set(Date(), forKey: "initial_date")
                                UserDefaults.standard.set(true, forKey: "trial_expired")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    } else if p.unit == .week {
                        if let nextDate = Calendar.current.date(byAdding: .day, value: (p.numberOfUnits * 7), to: initialDate) {
                            if nextDate.interval(ofComponent: .day, fromDate: initialDate) > (p.numberOfUnits * 7) {
                                UserDefaults.standard.set(Date(), forKey: "initial_date")
                                UserDefaults.standard.set(true, forKey: "trial_expired")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    } else if p.unit == .month {
                        if let nextDate = Calendar.current.date(byAdding: .month, value: p.numberOfUnits, to: initialDate) {
                            if nextDate.interval(ofComponent: .month, fromDate: initialDate) > p.numberOfUnits {
                                UserDefaults.standard.set(Date(), forKey: "initial_date")
                                UserDefaults.standard.set(true, forKey: "trial_expired")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    } else if p.unit == .year {
                        if let nextDate = Calendar.current.date(byAdding: .year, value: p.numberOfUnits, to: initialDate) {
                            if nextDate.interval(ofComponent: .year, fromDate: initialDate) > p.numberOfUnits {
                                UserDefaults.standard.set(Date(), forKey: "initial_date")
                                UserDefaults.standard.set(true, forKey: "trial_expired")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    }
                }
                
                if UserDefaults.standard.bool(forKey: "\(product.productIdentifier)_trial") == false {
                    
                    AppsFlyerTracker.shared().trackEvent(
                        AFEventStartTrial,
                        withValues: [
                            AFEventParamContentId: product.productIdentifier,
                            "source": "wrong_subscription_detecting"
                        ]
                    )
                    
                    UserDefaults.standard.set(true, forKey: "\(product.productIdentifier)_trial")
                    UserDefaults.standard.synchronize()
                    
                    return
                }
                
            }
            
            initialDate = UserDefaults.standard.object(forKey: "initial_date") as! Date
            
            if let p = product.subscriptionPeriod {
                
                var newNextDate = initialDate
                
                if p.unit == .day {
                    if let nextDate = Calendar.current.date(byAdding: .day, value: p.numberOfUnits, to: initialDate) {
                        newNextDate = nextDate
                        if nextDate.interval(ofComponent: .day, fromDate: initialDate) > p.numberOfUnits {
                            newNextDate = Calendar.current.date(byAdding: .day, value: (p.numberOfUnits * 2), to: initialDate)!
                            UserDefaults.standard.set(nextDate, forKey: "initial_date")
                            UserDefaults.standard.synchronize()
                        }
                    }
                } else if p.unit == .week {
                    if let nextDate = Calendar.current.date(byAdding: .day, value: (p.numberOfUnits * 7), to: initialDate) {
                        newNextDate = nextDate
                        if nextDate.interval(ofComponent: .day, fromDate: initialDate) > (p.numberOfUnits * 7) {
                            newNextDate = Calendar.current.date(byAdding: .day, value: (p.numberOfUnits * 7 * 2), to: initialDate)!
                            UserDefaults.standard.set(nextDate, forKey: "initial_date")
                            UserDefaults.standard.synchronize()
                        }
                    }
                } else if p.unit == .month {
                    if let nextDate = Calendar.current.date(byAdding: .month, value: p.numberOfUnits, to: initialDate) {
                        newNextDate = nextDate
                        if nextDate.interval(ofComponent: .month, fromDate: initialDate) > p.numberOfUnits {
                            newNextDate = Calendar.current.date(byAdding: .month, value: (p.numberOfUnits * 2), to: initialDate)!
                            UserDefaults.standard.set(nextDate, forKey: "initial_date")
                            UserDefaults.standard.synchronize()
                        }
                    }
                } else if p.unit == .year {
                    if let nextDate = Calendar.current.date(byAdding: .year, value: p.numberOfUnits, to: initialDate) {
                        newNextDate = nextDate
                        if nextDate.interval(ofComponent: .year, fromDate: initialDate) > p.numberOfUnits {
                            newNextDate = Calendar.current.date(byAdding: .year, value: (p.numberOfUnits * 2), to: initialDate)!
                            UserDefaults.standard.set(nextDate, forKey: "initial_date")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let key = "\(df.string(from: newNextDate))_\(product.productIdentifier)"
                //                let keyPrev = "\(df.string(from: Calendar.current.date(byAdding: .day, value: -1, to: newNextDate)!))_\(product.productIdentifier)"
                //                let keyNext = "\(df.string(from: Calendar.current.date(byAdding: .day, value: 1, to: newNextDate)!))_\(product.productIdentifier)"
                
                if UserDefaults.standard.bool(forKey: key) == false
                    //                    && UserDefaults.standard.bool(forKey: keyPrev) == false
                    //                    && UserDefaults.standard.bool(forKey: keyNext) == false
                {
                    
                    if UserDefaults.standard.bool(forKey: UserDefaults.standard.string(forKey: "last_subscription") ?? "") {
                        AppsFlyerTracker.shared().trackEvent(
                            AFEventSubscribe,
                            withValues: [
                                AFEventParamContentId: product.productIdentifier,
                                AFEventParamRevenue: product.price,
                                AFEventParamCurrency: (product.priceLocale.currencyCode ?? "USD").uppercased(),
                                "renewal": true,
                                "source": "wrong_subscription_detecting"
                            ]
                        )
                    } else {
                        AppsFlyerTracker.shared().trackEvent(
                            AFEventSubscribe,
                            withValues: [
                                AFEventParamContentId: product.productIdentifier,
                                AFEventParamRevenue: product.price,
                                AFEventParamCurrency: (product.priceLocale.currencyCode ?? "USD").uppercased(),
                                "renewal": false,
                                "source": "wrong_subscription_detecting"
                            ]
                        )
                    }
                    
                    UserDefaults.standard.set(key, forKey: "last_subscription")
                    UserDefaults.standard.set(true, forKey: key)
                    UserDefaults.standard.synchronize()
                }
            }
            
        } else if UserDefaults.standard.bool(forKey: product.productIdentifier) == false {
            AppsFlyerTracker.shared().trackEvent(
                AFEventPurchase,
                withValues: [
                    AFEventParamContentId: product.productIdentifier,
                    AFEventParamRevenue: product.price,
                    AFEventParamCurrency: (product.priceLocale.currencyCode ?? "USD").uppercased()
                ]
            )
            
            UserDefaults.standard.set(true, forKey: product.productIdentifier)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    public func trackSubscription(product: SKProduct, isTrial: Bool, expirationDate: Date) {
        if self.purchaseIds.contains(product.productIdentifier.lowercased()) ||
            product.productIdentifier.lowercased().contains("purchase") {
            
            if UserDefaults.standard.bool(forKey: product.productIdentifier) == false {
                AppsFlyerTracker.shared().trackEvent(
                    AFEventPurchase,
                    withValues: [
                        AFEventParamContentId: product.productIdentifier,
                        AFEventParamRevenue: product.price,
                        AFEventParamCurrency: (product.priceLocale.currencyCode ?? "USD").uppercased()
                    ]
                )
                
                UserDefaults.standard.set(true, forKey: product.productIdentifier)
                UserDefaults.standard.synchronize()
            }
            
        } else {
            if isTrial {
                if UserDefaults.standard.bool(forKey: "\(product.productIdentifier)_trial") == false {
                    
                    AppsFlyerTracker.shared().trackEvent(
                        AFEventStartTrial,
                        withValues: [
                            AFEventParamContentId: product.productIdentifier,
                            "source": "right_subscription_detecting"
                        ]
                    )
                    
                    UserDefaults.standard.set(true, forKey: "\(product.productIdentifier)_trial")
                    UserDefaults.standard.synchronize()
                    
                }
            } else {
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let key = "\(df.string(from: expirationDate))_\(product.productIdentifier)"
                let keyPrev = "\(df.string(from: Calendar.current.date(byAdding: .day, value: -1, to: expirationDate)!))_\(product.productIdentifier)"
                let keyNext = "\(df.string(from: Calendar.current.date(byAdding: .day, value: 1, to: expirationDate)!))_\(product.productIdentifier)"
                
                if UserDefaults.standard.bool(forKey: key) == false &&
                    UserDefaults.standard.bool(forKey: keyPrev) == false &&
                    UserDefaults.standard.bool(forKey: keyNext) == false {
                    if UserDefaults.standard.bool(forKey: UserDefaults.standard.string(forKey: "last_subscription") ?? "") {
                        AppsFlyerTracker.shared().trackEvent(
                            AFEventSubscribe,
                            withValues: [
                                AFEventParamContentId: product.productIdentifier,
                                AFEventParamRevenue: product.price,
                                AFEventParamCurrency: (product.priceLocale.currencyCode ?? "USD").uppercased(),
                                "renewal": true,
                                "source": "right_subscription_detecting"
                            ]
                        )
                    } else {
                        AppsFlyerTracker.shared().trackEvent(
                            AFEventSubscribe,
                            withValues: [
                                AFEventParamContentId: product.productIdentifier,
                                AFEventParamRevenue: product.price,
                                AFEventParamCurrency: (product.priceLocale.currencyCode ?? "USD").uppercased(),
                                "renewal": false,
                                "source": "right_subscription_detecting"
                            ]
                        )
                    }
                    
                    UserDefaults.standard.set(key, forKey: "last_subscription")
                    UserDefaults.standard.set(true, forKey: key)
                    UserDefaults.standard.synchronize()
                    
                }
            }
        }
        
    }
    
}
