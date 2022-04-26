//
//  AdvertisementViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit

class AdvertisementViewController: UIViewController {
    
    @IBOutlet weak var advertisementView: UIView!
    @IBOutlet weak var advertisementHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var advertisementBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
		setupAdvertisementView()
        updateColors()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension AdvertisementViewController: UpdateColorsDelegate {
    
    private func setupUI() {
        
//        TODO:
		
		
		
		
		
        
        // if device has top notch and no premium users
//        containerViewBottomConstraint.constant = -U.bottomSafeAreaHeight ???
        self.view.layoutIfNeeded()
        // else {
//      advertisementBottomConstraint.constant = 0
//
//        if not premium  with advetisement
//        need show container advertisment higer than other
    }
    
    func updateColors() {
        self.view.backgroundColor = theme.backgroundColor
    }
    
    func setupNavigation() {
        
        self.navigationController?.updateNavigationColors()
    }
}

extension AdvertisementViewController {
	
	private func setupAdvertisementView() {
		
		let advertisementHeigh: CGFloat = S.premium.allowAdvertisementBanner ? 50 : -U.bottomSafeAreaHeight
		let containerHeignt = advertisementHeigh + U.bottomSafeAreaHeight
		advertisementHightConstraint.constant = containerHeignt
	}
}
