//
//  GeoManager.swift
//  cisua
//
//  Created by Anton Litvinov on 1/29/19.
//


internal class GeoManager {
    
    internal struct IpServiceModel: Hashable {
        
        let url: String
        let key: String
        
        static func ==(lhs: GeoManager.IpServiceModel, rhs: GeoManager.IpServiceModel) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
    
    fileprivate static let ipInfoProviders = [
        IpServiceModel(
            url: "https://pro.ip-api.com/json/?key=ynjv7kObjkhUFx9&fields=2",
            key: "countryCode"
        )
    ]
    
    internal class func refreshCountry(_ finished: (()->())? = nil) {
        DispatchQueue.global().async {
            let country = UserDefaults.standard.string(forKey: "country") ?? ""
            let now = Date()
            let updated = UserDefaults.standard.double(forKey: "updated")
            let dif = abs(Date(timeIntervalSince1970: updated).timeIntervalSince(now))
            let seconds: Double = 60 * 60 * 24
            
            if country == "" || (dif > seconds) {
                self.getUsersCountry(self.ipInfoProviders) { (country) in
                    UserDefaults.standard.set(country, forKey: "country")
                    UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "updated")
                    UserDefaults.standard.synchronize()
                    DispatchQueue.main.async {
                        finished?()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    finished?()
                }
            }
        }
    }
    
    fileprivate class func getUsersCountry(_ providers: [IpServiceModel], result: ((String) -> Void)?) {
        let index = Int(arc4random_uniform(UInt32(providers.count)))
        let provider = providers[index]
        self.makeRequest(
            provider.url,
            success: {
                if let v = $0[provider.key] as? String, v.count == 2 {
                    result?(v.lowercased())
                    return
                }
                
                var providersNew = providers
                if let index = providersNew.firstIndex(of: provider) {
                    providersNew.remove(at: index)
                }
                if providersNew.count > 0 {
                    self.getUsersCountry(providersNew, result: result)
                    return
                }
                result?("")
            },
            failure: {
                var providersNew = providers
                if let index = providersNew.firstIndex(of: provider) {
                    providersNew.remove(at: index)
                }
                if providersNew.count > 0 {
                    self.getUsersCountry(providersNew, result: result)
                    return
                }
                result?("")
            }
        )
        
    }
    
    fileprivate class func makeRequest(_ url: String, success: (([String: Any]) -> ())?, failure: (() -> ())?) {
        if let url = URL(string: url) {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    success?(json)
                    return
                }
                failure?()
            }
            task.resume()
            return
        }
        failure?()
    }
}
