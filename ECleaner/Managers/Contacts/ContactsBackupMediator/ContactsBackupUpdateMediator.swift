//
//  ContactsBackupUpdateMediator.swift
//  ECleaner
//
//  Created by alexey sorochan on 18.07.2022.
//

import Foundation

class ContactsBackupUpdateMediator {
	
	class var instance: ContactsBackupUpdateMediator {
		struct Static {
			static let instance: ContactsBackupUpdateMediator = ContactsBackupUpdateMediator()
		}
		return Static.instance
	}
	
	private var listener: ContactsBackupUpdateListener?
	private init() {}
	
	func setListener(listener: ContactsBackupUpdateListener) {
		self.listener = listener
	}

	func updateStatus(with status: ContactsBackupStatus) {
		listener?.didUpdateStatus(status)
	}
	
	func updateProgres(with name: String, currentIndex: Int, total files: Int) {
		let progress = CGFloat(Double(currentIndex) / Double(files))
		listener?.didUpdateProgress(with: name, progress: progress)
	}
}
