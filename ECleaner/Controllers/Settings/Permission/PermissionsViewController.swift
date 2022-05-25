//
//  PermissionsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import UIKit

class PermissionsViewController: UIViewController {
	
	let string = "hello"

    override func viewDidLoad() {
        super.viewDidLoad()

		debugPrint("viewDidLoad")
		self.view.backgroundColor = .red
    }
	
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		
		debugPrint("viewDidAppear")
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		debugPrint("viewDidDisappear")
	}
}
