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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateColors()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension AdvertisementViewController: UpdateColorsDelegate {
    
    func updateColors() {
        self.view.backgroundColor = currentTheme.backgroundColor
    }
    
    func setupNavigation() {
        
        self.navigationController?.updateNavigationColors()
    }
}



