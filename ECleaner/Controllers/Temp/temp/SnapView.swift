//
//  SnapView.swift
//  ECleaner
//
//  Created by alexey sorochan on 15.02.2022.
//

import UIKit

protocol SnapView: UIView {
	func setupUI()
	func createConstraints()
}
