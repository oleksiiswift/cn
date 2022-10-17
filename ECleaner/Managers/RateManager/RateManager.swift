//
//  RateManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 15.08.2022.
//

import Foundation
import SwiftRater

enum Rate {
	case objc
	case swift
}

enum PeriodPromt {
	case days
	case hours
}

class RateManager: NSObject {
	
	class var instance: RateManager {
		struct Static {
			static let instace: RateManager = RateManager()
		}
		return Static.instace
	}
	
	private var handlerPeriod: PeriodPromt = .hours
	
	private override init() {}

	public func initialize(rate: Rate) {
				
		switch rate {
			case .objc:
				self.iRateInitialize()
			case .swift:
				self.swiftRateInitialize()
		}
	}
	
	private func iRateInitialize() {
		
		self.configurePromt()
		self.registerNotification()
		Utils.delay(10) {
			SettingsManager.promt.firstTimePromtShow ? self.promtEventHandler() : self.firstPromtEvent()
		}
	}
	
	private func swiftRateInitialize() {
		self.configureSwiftPromt()
	}
	
	public func promtForRate(type: Rate) {
		
		switch type {
			case .objc:
				iRate.sharedInstance().promptForRating()
			case .swift:
				SwiftRater.check(host: topController())
		}
	}
}

extension RateManager {
	
	private func configureSwiftPromt() {
		
		SwiftRater.daysUntilPrompt = 0
		SwiftRater.usesUntilPrompt = 1
		SwiftRater.daysBeforeReminding = 1
		SwiftRater.showLaterButton = true
		SwiftRater.showLog = true
		SwiftRater.appID = Constants.project.appID
		/// `debuging - in app store set to false`
		SwiftRater.debugMode = false
		SwiftRater.appLaunched()
	}
	
	private func swiftPromtEventHandler() {
		
		
	}
	
	private func swiftFirstPromtEvent() {
		
	}
}


extension RateManager {
	
	private func registerNotification() {
		
		Utils.notificationCenter.addObserver(self, selector: #selector(didCancelPromtRequest), name: .didCancelPromtRequest , object: nil)
	}
	
	private func configurePromt() {
		
		if let appID = UInt(Constants.project.appID) {
			iRate.sharedInstance().appStoreID = appID
		}
		iRate.sharedInstance().applicationBundleID = Utils.bundleIdentifier
		iRate.sharedInstance().eventsUntilPrompt = 5
		iRate.sharedInstance().onlyPromptIfLatestVersion = false
		iRate.sharedInstance().useSKStoreReviewControllerIfAvailable = true

		if iRate.sharedInstance().eventCount == 0 {
			iRate.sharedInstance().daysUntilPrompt = 0
			iRate.sharedInstance().usesUntilPrompt = 2
		}
	}
	
	@objc func shoulPromtForRequest() {
		Utils.delay(180) {
			iRate.sharedInstance().promptForRating()
		}
	}
	
	@objc func didCancelPromtRequest() {
		
		switch self.handlerPeriod {
			case .days:
				self.daysPromtDelay()
			case .hours:
				SettingsManager.promt.promtRateDelay = Date.getCurrentDate()
		}
	}
	
	private func daysPromtDelay() {
		
		let day: Float = 1
		iRate.sharedInstance().eventCount += 1
		
		switch iRate.sharedInstance().eventCount {
			case 1:
				iRate.sharedInstance().remindPeriod = day
			case 2:
				iRate.sharedInstance().remindPeriod = day * 2
			case 3:
				iRate.sharedInstance().remindPeriod = day * 3
			default:
				return
		}
	}
	
	private func firstPromtEvent() {
		let now = Date.getCurrentDate()
		
		if let sixHoursDelay = SettingsManager.promt.sixHoursDelay {
			if sixHoursDelay + 32400 < now { // 32400
				iRate.sharedInstance().promptForRating()
				SettingsManager.promt.firstTimePromtShow = true
			}
		}
	}
	
	private func promtEventHandler() {
		
		let now = Date.getCurrentDate()
		iRate.sharedInstance()?.ratedThisVersion = false
		
		if !iRate.sharedInstance().ratedAnyVersion {
			if let delay = SettingsManager.promt.promtRateDelay {
				if delay + 25920 < now { // 25920
					iRate.sharedInstance().promptForRating()
					SettingsManager.promt.promtRateDelay = now
				}
			}
		}
	}
}
