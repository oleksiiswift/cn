//
//  Api.swift
//  cisua
//
//  Created by admin on 22/02/2018.
//  Copyright © 2018 cisua. All rights reserved.
//

import Foundation


internal struct Api {

    internal static let scheme = "https://"
    internal static let domain = "cisua.tk"
    
    internal static let userAgent   = "api/cisua"
    internal static let lang        = Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
    
    internal struct Boost {
        private static let base         = Api.scheme + "boost." + Api.domain + "/ios/"
        internal static let redirected  = base + "redirected.php"
        internal static let showed      = base + "showed.php"
        internal static let request     = base + "request.php"
    }
    
    internal struct PushNotifications {
        private static let base         = Api.scheme + "api." + Api.domain + "/push/ios/"
        internal static let register    = base + "register.php"
        internal static let opened      = base + "opened.php"
        internal static let redirected  = base + "redirected.php"
    }
    
    internal struct Similar {
        private static let base         = Api.scheme + "api." + Api.domain + "/similar/"
        private static let path         = base + "ios/"
        internal static let imagePath   = base + "images/"
        internal static let updated     = path + "updated.php"
        internal static let similar     = path + "similar.php"
        internal static let our         = path + "our.php"
        internal static let paid        = path + "paid.php"
    }
    
    internal struct Emails {
        private static let base         = Api.scheme + "api." + Api.domain + "/emails/ios/"
        internal static let register    = base + "register.php"
    }
    
}
