//
//  StoryBoarded.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2022.
//

import UIKit

protocol Storyboarded {
//	static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
	
	static func instantiate(type: PresentedControllerType) -> Self {
		let storyboard = UIStoryboard(name: type.storyboardName, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: type.viewControllerIdentifier) as! Self
	}
}
