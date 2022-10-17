//
//  ContactBackUpPageViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 15.10.2022.
//

import UIKit

class ContactBackUpPageViewController: UIViewController {
	
	init() {
		super.init(nibName: Constants.identifiers.xibs.contactsBackUpPage, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		
        updateColors()
    }
}


extension ContactBackUpPageViewController: UpdateColorsDelegate {
	
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
	}
}
