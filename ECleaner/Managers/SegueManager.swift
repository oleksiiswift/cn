//
//  SegueManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2021.
//

import UIKit
import SwiftMessages

class ShowDatePickerLowerDateSelectorViewController: SwiftMessagesSegue {
    
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomMessage)
        dimMode = .gray(interactive: false)
        messageView.configureNoDropShadow()
    }
}

class ShowDatePickerUpperDateSelectorViewController: SwiftMessagesSegue {
	
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
    }
}

class ShowVideoSizeSelectorViewControllerSegue: SwiftMessagesSegue {
	
	override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
		super.init(identifier: identifier, source: source, destination: destination)
		configure(layout: .bottomMessage)
		dimMode = .gray(interactive: false)
		messageView.configureDropShadow()
	}
}

class ShowVideoCompressionCustomSettingsSelectorViewControllerSegue: SwiftMessagesSegue {
	
	override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
		super.init(identifier: identifier, source: source, destination: destination)
		configure(layout: .bottomMessage)
		dimMode = .gray(interactive: false)
		messageView.configureDropShadow()
	}
}


class ShowLifeTimeViewControllerSegue: SwiftMessagesSegue {
	
	override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
		super.init(identifier: identifier, source: source, destination: destination)
		configure(layout: .bottomMessage)
		dimMode = .gray(interactive: false)
		messageView.configureNoDropShadow()
	}
}

class ShowContactsBackupViewControllerSegue: SwiftMessagesSegue {
	
	override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
		super.init(identifier: identifier, source: source, destination: destination)
		configure(layout: .bottomMessage)
		dimMode = .gray(interactive: false)
		messageView.configureNoDropShadow()
	}
}
