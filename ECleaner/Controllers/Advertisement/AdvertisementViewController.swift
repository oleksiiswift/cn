//
//  AdvertisementViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit
import GoogleMobileAds

class AdvertisementViewController: UIViewController {
    
    @IBOutlet weak var advertisementView: UIView!
    @IBOutlet weak var advertisementHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var advertisementBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
	
	private var subscriptionManager = SubscriptionManager.instance
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
		handleAdvertisementSetup()
        updateColors()
        setupNavigation()
		addSubscriptionChangeObserver()
		setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
    }
}

extension AdvertisementViewController: SubscriptionObserver {
	
	private func handleAdvertisementSetup() {
		
		switch subscriptionManager.applicationDevelopmentSubscriptionStatus {
			case .production:
				self.productionSetup()
			case .premiumSimulated, .lifeTimeSimulated:
				self.advertisementHandler(status: .hiden)
			case .limitedSimulated:
				self.advertisementHandler(status: .active)
		}
	}
	
	private func productionSetup() {
		
		Network.theyLive { status in
			switch status {
				case .connedcted:
					SubscriptionManager.instance.purchasePremiumHandler { status in
						Utils.UI {
							switch status {
								case .lifetime, .purchasedPremium:
									if Advertisement.manager.advertisementBannerStatus != .hiden {
										self.advertisementHandler(status: .hiden)
									}
								case .nonPurchased:
									if Advertisement.manager.advertisementBannerStatus != .active {
										self.setupAdvertisemenetBanner()
										self.advertisementHandler(status: .active)
									}
							}
						}
					}
				case .unreachable:
					self.advertisementHandler(status: .hiden)
			}
		}
	}
	
	func setupAdvertisemenetBanner() {
		
		let size = GADAdSizeFullWidthPortraitWithHeight(50)
		var advertisementBannerView: GADBannerView!
		advertisementBannerView = GADBannerView(adSize: size)
		advertisementBannerView.adUnitID = Advertisement.manager.getUnitID(for: .testing)
		advertisementBannerView.tag = Advertisement.manager.advertimentBannerTag
		advertisementBannerView.delegate = self
		advertisementBannerView.rootViewController = self
		advertisementBannerView.load(GADRequest())
		self.advertisementView.addSubview(advertisementBannerView)
	}
	
	func subscriptionDidChange() {
		self.handleAdvertisementSetup()
	}
	
	@objc func networkStatusDidChange() {
		self.handleAdvertisementSetup()
	}
}

extension AdvertisementViewController: Themeble {
    
    private func setupUI() {}
	
    func updateColors() {
        self.view.backgroundColor = theme.backgroundColor
		self.advertisementView.backgroundColor = theme.backgroundColor
    }
    
    func setupNavigation() {
        self.navigationController?.updateNavigationColors()
    }
	
	func setupObserver() {
		U.notificationCenter.addObserver(self, selector: #selector(networkStatusDidChange), name: .ConnectivityDidChange, object: nil)
	}
}

extension AdvertisementViewController {
	
	private func advertisementHandler(status: AdvertisementStatus) {
		
		Advertisement.manager.advertisementBannerStatus = status
		
		var advertisemntContaineHeight: CGFloat {
			switch status {
				case .active:
					return 45 + U.bottomSafeAreaHeight
				case .hiden:
					return 0
			}
		}
		
		self.advertisementHightConstraint.constant = advertisemntContaineHeight
		
		if status == .hiden {
			if let view = self.advertisementView.viewWithTag(Advertisement.manager.advertimentBannerTag) {
				view.removeFromSuperview()
			}
		}
		
		UIView.animate(withDuration: 0.3) {
//			self.view.layoutIfNeeded()
			self.advertisementView.layoutIfNeeded()
		} completion: { _ in }
	}
}

extension AdvertisementViewController: GADBannerViewDelegate {
	
	func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
	  print("bannerViewDidReceiveAd")
	}

	func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
	  print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
	}
	
	func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
	  print("bannerViewDidRecordImpression")
	}

	func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
	  print("bannerViewWillPresentScreen")
	}

	func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
	  print("bannerViewWillDIsmissScreen")
	}

	func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
	  print("bannerViewDidDismissScreen")
	}
}
