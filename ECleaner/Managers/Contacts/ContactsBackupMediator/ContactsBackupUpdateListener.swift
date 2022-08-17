//
//  ContactsBackupUpdateListener.swift
//  ECleaner
//
//  Created by alexey sorochan on 18.07.2022.
//

import Foundation

protocol ContactsBackupUpdateListener {
	func didUpdateStatus(_ status: ContactsBackupStatus)
	func didUpdateProgress(with name: String, progress: CGFloat)
}
