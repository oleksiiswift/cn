//
//  Utils.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.06.2021.
//

import Foundation
import UIKit

typealias U = Utils
class Utils {
    
//    MARK: - DEFAULT VALUES -
    
    static let appName: String = Bundle.main.appName
    
    static let userDefaults: UserDefaults = .standard
    
    static let application: UIApplication = .shared
    
    static let topLevel: UIWindow.Level = .statusBar
    
    static let device: UIDevice = .current
    
    static let appDelegate: AppDelegate = application.delegate as! AppDelegate
	
	static let scene = UIApplication.shared.connectedScenes.first
	
	static let sceneDelegate: SceneDelegate = scene!.delegate as! SceneDelegate
    
    static let locale: Locale = .current
    
    static let mainBundle: Bundle = .main
    
    static let bundleIdentifier = mainBundle.bundleIdentifier
    
//     MARK: - UI VALUES -
    
    static let mainScreen: UIScreen = .main
    
    static let screenBounds: CGRect = mainScreen.bounds
    
    static let screenHeight: CGFloat = screenBounds.height
    
    static let screenWidth: CGFloat = screenBounds.width
    
    static let ratio: CGFloat = U.screenWidth / U.screenHeight
    
    static let window = U.application.windows.filter { $0.isKeyWindow}.first
    
    static let windowScene = UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
    
    static let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
    
//    MARK: - HELPERS -
    
    static let notificationCenter: NotificationCenter = .default
    
    static let pasteboard = UIPasteboard.general
    
    static let appSettings = UIApplication.openSettingsURLString
    
//    MARK: - DEVICES -
    
    static let isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    static let isSmallDevice: Bool = mainScreen.bounds.size.height <= 667
    
    static let isLandscapeOrientation = device.orientation.isLandscape
    
    static public var hasTopNotch: Bool {
        return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0 > 20
    }
    
    static public var bottomSafeAreaHeight: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
	
	static public var topSafeAreaHeight: CGFloat {
		return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
	}
    
    static let isSimulator = UIDevice.isSimulator
    
//    MARK: - DATE and TIME
    
    static let currentDate = Date.getCurrentDate()
}

//  MARK: - User Defaults -
extension Utils {
        
    static func contains(_ key: String) -> Bool {
        return U.userDefaults.object(forKey: key) != nil
    }
    
    static func resetAllUserDefaults() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { (key) in
            userDefaults.removeObject(forKey: key)
        }
    }
}

//      MARK: - Native Settings -

extension Utils {
    
    static func openSettings() {
        DispatchQueue.main.async {
            U.application.open(URL(string: appSettings)!)
        }
    }
}

//    MARK: - Grand Central Dispatch -
extension Utils {

    static func delay(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
	
    /// main
    static func UI(_ block: @escaping () -> Void) {
        DispatchQueue.main.async(execute: block)
    }
    
    /// main after
    static func UI(after: Float, _ block: @escaping ()->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: block)
    }
    
    /// background
    static func BG(_ block: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async(execute: block)
    }
    
    /// background delay
    static func BGD(after: Float,_ block: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5, execute: block)
    }
    
    /// global
    static func GLB(qos: DispatchQoS.QoSClass,_ block: @escaping () -> Void) {
        DispatchQueue.global(qos: qos).async(execute: block)
    }
}

extension Utils {
    
    static func animate(_ duration: TimeInterval, delay: TimeInterval = 0.0, animation: @escaping () -> Void, completion: (() -> Void)? = nil) {
        
        UIView.animate(withDuration: duration, delay: delay) {
            animation()
        } completion: { (_) in
            completion?()
        }
    }
}

//      MARK: - get the most top view controller - 
func topController() -> UIViewController? {
    if var controller = UIApplication.shared.windows.first?.rootViewController {
        while let presentedViewController = controller.presentedViewController {
            controller = presentedViewController
        }
        return controller
    }
    return nil
}

func getTheMostTopController(controller: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
        return getTheMostTopController(controller: navigationController.visibleViewController)
    } else if let presentedViewController = controller?.presentedViewController {
        return getTheMostTopController(controller: presentedViewController)
    } else if let tabbarViewController = controller as? UITabBarController, let selectedController = tabbarViewController.selectedViewController {
        return getTheMostTopController(controller: selectedController)
    } else if let rootController = U.window?.rootViewController {
        while let presentedViewController = rootController.presentedViewController {
            return presentedViewController
        }
	} else if let keyWindowContreoller = U.keyWindow?.rootViewController {
		while let presentedViewController =  keyWindowContreoller.presentedViewController {
			return presentedViewController
		}
	}
    return controller!
}

extension Utils {

    static func getSpaceFromInt(_ count: Int64) -> String {
        
        let bytes = Int(truncatingIfNeeded: count)
        
        if (bytes < 1000) {
            return "\(bytes) B"
        }
        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        
        let number = Double(bytes) / pow(1000, Double(exp))
        
        if exp <= 1 || number >= 100 {
            return String(format: "%.0f %@", number, unit)
        } else {
            return String(format: "%.1f %@", number, unit)
                .replacingOccurrences(of: ".0", with: "")
        }
    }
}

//      MARK: - Date time manager

extension Utils {
        
    static func getString(from date: Date, format: String) -> String {
        return Date().convertDateFormatterFromDate(date: date, format: format)
    }
    
    static func convertStringDateFormated(date: String) -> String {
        return Date().convertDateFormatterFromSrting(stringDate: date)
    }
    
    static func displayDate(from stringDate: String) -> String {
        return Date().convertDateFormatterToDisplayString(stringDate: stringDate)
    }
    
    static func getDateFrom(string date: String, format: String) -> Date? {
        return Date().getDateFromString(stringDate: date, format: format)
    }

	static func numbersOfDays(at month: Int, in year: Int) -> Int {
		let calendar = Calendar(identifier: .gregorian)
		var components = DateComponents()
		components.day = 1
		components.month = month
		components.year = year
		return (calendar as NSCalendar).range(of: .day, in: .month, for: calendar.date(from: components)!).length
	}
	
	static func getDateFromComponents(day: Int, month: Int, year: Int) -> Date {
		let calendar = Calendar(identifier: .gregorian)
		var components = DateComponents()
		components.day = day
		components.month = month
		components.year = year
		components.timeZone = TimeZone(secondsFromGMT: 0)
		return calendar.date(from: components)!
	}
	
	static func setUpperDefaultValue() {
		
		let currentDay = Date()
		let numbersOfDayInThisMonth = numbersOfDays(at: currentDay.getMonth(), in: currentDay.getYear())
		let upperDate = getDateFromComponents(day: numbersOfDayInThisMonth, month: currentDay.getMonth(), year: currentDay.getYear())
		S.upperBoundSavedDate = upperDate
	}
	
	static func setLowerDafaultValue() {
		S.lowerBoundSavedDate = Date(timeIntervalSinceReferenceDate: 0)
	}
}

//  TODO: temp get name from bundle, for future get localized app name
internal extension Bundle {
    
    var appName: String {
        if let bundleName = self.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String {
            return bundleName
        }
        return ""
    }
}

extension Utils {

	static func getReadableResulotion(from size: CGSize) -> String {
		return "\(Int(size.width.rounded())) x \(Int(size.height.rounded()))"
	}
}


class Hello: NSObject {
    
    private static let shared = Hello()
    
    static var sharedInstance: Hello {
        return self.shared
    }
}
