//
//  UpdateMediaStoreSizeDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.05.2022.
//

import Foundation

protocol UpdateMediaStoreSizeDelegate {
	func didStartUpdatingMediaSpace(photo: Int64?, video: Int64?)
}
