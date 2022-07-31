//
//  AdvertisementViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit

enum AdvertisementStatus {
	case active
	case hiden
}

class AdvertisementViewController: UIViewController {
    
    @IBOutlet weak var advertisementView: UIView!
    @IBOutlet weak var advertisementHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var advertisementBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
		subscriptionDidChange()
        updateColors()
        setupNavigation()
		addSubscriptionChangeObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension AdvertisementViewController: SubscriptionObserver {
	
	func subscriptionDidChange() {
		
		SubscriptionManager.instance.purchasePremiumHandler { status in
			switch status {
				case .lifetime, .purchasedPremium:
					self.advertisementHandler(status: .hiden)
				case .nonPurchased:
					self.advertisementHandler(status: .hiden)
			}
		}
	}
}

extension AdvertisementViewController: Themeble {
    
    private func setupUI() {}
	
    func updateColors() {
        self.view.backgroundColor = theme.backgroundColor
		
    }
    
    func setupNavigation() {
        self.navigationController?.updateNavigationColors()
    }
}

extension AdvertisementViewController {
	
	private func advertisementHandler(status: AdvertisementStatus) {
		
		Utils.UI {
			var advertisemntContaineHeight: CGFloat {
				switch status {
					case .active:
						return 45 + U.bottomSafeAreaHeight
					case .hiden:
						return 0
				}
			}
			
			self.advertisementHightConstraint.constant = advertisemntContaineHeight
			
			UIView.animate(withDuration: 0.3) {
				self.view.layoutIfNeeded()
			}
		}
	}
}

