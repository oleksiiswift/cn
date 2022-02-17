//
//  SegueManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2021.
//

import UIKit
import SwiftMessages

class ShowDatePickerSelectorViewControllerSegue: SwiftMessagesSegue {
    
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomMessage)
        dimMode = .gray(interactive: false)
        messageView.configureNoDropShadow()
    }
}

class ShowExportContactsViewControllerSegue: SwiftMessagesSegue {
    
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomMessage)
        dimMode = .gray(interactive: false)
        messageView.configureNoDropShadow()
        messageView.configureDropShadow()
    }
}

class ShowVideoSizeSelectorViewControllerSegue: SwiftMessagesSegue {
	
	override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
		super.init(identifier: identifier, source: source, destination: destination)
		configure(layout: .bottomMessage)
		dimMode = .gray(interactive: false)
		messageView.configureNoDropShadow()
		messageView.configureDropShadow()
	}
}
