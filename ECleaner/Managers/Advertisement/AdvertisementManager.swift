//
//  AdvertisementManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.08.2022.
//

import Foundation
import GoogleMobileAds
import UIKit

enum AdvertisementStatus: Int {
	case active
	case hiden
}

enum GadUnitKey {
	case production
	case testing
}

enum GadInterstitalUnitKey {
	case production
	case testing
}

enum GadRewardedUnitKey {
	case production
	case testing
}

enum GadRewardedInterstitialUnitKey {
	case production
	case testing
}

enum InterstitialLoadStatus {
	case load
	case error
}

enum RewardedLoadStatus {
	case load
	case error
}

enum InterstitialRewardedRegisteredStatus {
	case registered
	case error
}

class Advertisement: NSObject {
	
	static var manager: Advertisement {
		return self.shared
	}
	
	private static let shared = Advertisement()
	
	public var advertisementBannerStatus: AdvertisementStatus {
		get {
			let statusRawValue: Int = U.userDefaults.integer(forKey: C.key.advertisement.bannerStatus)
			return AdvertisementStatus(rawValue: statusRawValue)!
		} set {
			U.userDefaults.set(newValue.rawValue, forKey: C.key.advertisement.bannerStatus)
			let userInfo = [C.key.advertisement.bannerStatus: newValue]
			U.notificationCenter.post(name: .bannerStatusDidChanged, object: nil, userInfo: userInfo)
		}
	}
	
	public var advertimentBannerTag: Int {
		return Constants.gadAdvertisementKey.advertisementViewTag
	}
	
	private var interstitial: GADInterstitialAd?
	private var rewardedInterstitialAd: GADRewardedInterstitialAd?
	private var rewardedAd: GADRewardedAd?
	
	public func getUnitID(for key: GadUnitKey) -> String {
		switch key {
			case .production:
				return Constants.gadAdvertisementKey.gadProductionKey
			case .testing:
				return Constants.gadAdvertisementKey.gadTestKey
		}
	}
	
	private func getInterstitialUnitKeyID(for key: GadInterstitalUnitKey) -> String {
		switch key {
			case .production:
				return Constants.gadAdvertisementKey.gadInterstitialProductionKey
			case .testing:
				return Constants.gadAdvertisementKey.gadInterstitialTestKey
		}
	}
	
	private func getRewardedUnitKeyID(for key: GadRewardedUnitKey) -> String {
		switch key {
			case .production:
				return Constants.gadAdvertisementKey.gadRewardedProductionKey
			case .testing:
				return Constants.gadAdvertisementKey.gadRewardedTestKey
		}
	}
	
	private func getRewardedInterstitalUnitID(for key: GadRewardedInterstitialUnitKey) -> String {
		switch key {
			case .production:
				return Constants.gadAdvertisementKey.gadRewardedIntProductionKey
			case .testing:
				return Constants.gadAdvertisementKey.gadRewardedIntTestKey
		}
	}
}

//	MARK: - INTERSTITIAL -
extension Advertisement {
	
	public func showInterstitial(from viewController: UIViewController, completionHandler: @escaping () -> Void) {
		
		self.loadInterstitialAd { status in
			switch status {
				case .load:
					if self.interstitial != nil {
						self.interstitial?.present(fromRootViewController: viewController)
						completionHandler()
					}
				case .error:
					print("Ad wasn't ready")
			}
		}
	}
	
	private func loadInterstitialAd(completionHandler: @escaping (_ status: InterstitialLoadStatus) -> Void) {
		
		let unitID = self.getInterstitialUnitKeyID(for: .testing)
		let request = GADRequest()
		GADInterstitialAd.load(withAdUnitID: unitID, request: request, completionHandler: { [self] ad, error in
			if let error = error {
				print("Failed to load interstitial ad with error: \(error.localizedDescription)")
				completionHandler(.error)
				return
			}
			interstitial = ad
			interstitial?.fullScreenContentDelegate = self
			completionHandler(.load)
		})
	}
}


//  MARK: - REWARDED -
extension Advertisement {
	
	public func showRewarded(from viewController: UIViewController, completionHandler: @escaping () -> Void) {
		
		self.loadRewardedAd { status in
			switch status {
				case .load:
					
					if let ad = self.rewardedAd {
						ad.present(fromRootViewController: viewController) {
							let reward = ad.adReward
							print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
							completionHandler()
						}
					}
				case .error:
					print("Ad wasn't ready")
			}
		}
	}
	
	private func loadRewardedAd(completionHadnler: @escaping (_ status: RewardedLoadStatus) -> Void) {
		
		let unitID = self.getRewardedUnitKeyID(for: .testing)
		let request = GADRequest()
		GADRewardedAd.load(withAdUnitID: unitID, request: request, completionHandler: { [self] ad, error in
			if let error = error {
				print("Failed to load rewarded ad with error: \(error.localizedDescription)")
				completionHadnler(.error)
				return
			}
			rewardedAd = ad
			rewardedAd?.fullScreenContentDelegate = self
			completionHadnler(.load)
			print("Rewarded ad loaded.")
		})
	}
}

//	MARK: - REWARDED INTERSTITAL -
extension Advertisement {
	
	public func showIntertstitalRewarded(from viewController: UIViewController, completionHandler: @escaping () -> Void) {
		
		self.registerrewardedInterstitialAd { status in
			
			guard let rewardedInterstitialAd = self.rewardedInterstitialAd else { return print("Ad wasn't ready.") }
			
			switch status {
				case .registered:
					rewardedInterstitialAd.present(fromRootViewController: viewController) {
						let _ = rewardedInterstitialAd.adReward
						completionHandler()
					}
				case .error:
					return
			}
		}
	}
	
	private func registerrewardedInterstitialAd(completionHandler: @escaping (_ status: InterstitialRewardedRegisteredStatus) -> Void) {
		
			///`set unit testing id`
		let unitID = self.getRewardedInterstitalUnitID(for: .testing)
		let request = GADRequest()
		
		GADRewardedInterstitialAd.load(withAdUnitID: unitID, request: request) { ad, error in
			
			if let error = error {
				completionHandler(.error)
				return print("Failed to load rewarded interstitial ad with error: \(error.localizedDescription)")
			}
			
			self.rewardedInterstitialAd = ad
			self.rewardedInterstitialAd?.fullScreenContentDelegate = self
			completionHandler(.registered)
		}
	}
}

extension Advertisement: GADFullScreenContentDelegate {
	
		/// Tells the delegate that the ad failed to present full screen content.
	func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
		print("Ad did fail to present full screen content.")
	}
	
		/// Tells the delegate that the ad will present full screen content.
	func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
		print("Ad will present full screen content.")
	}
	
		/// Tells the delegate that the ad dismissed full screen content.
	func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
		print("Ad did dismiss full screen content.")
	}
}
