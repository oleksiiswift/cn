//
//  AppDimensions.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.05.2022.
//

import Foundation

struct AppDimensions {
	
	private static let screenSize = Screen.size
}

/// `permission cells`
extension AppDimensions {
	
	struct PermissionsCell {
		
		public static func getHeightOfRow(at permissionType: Permission.PermissionType) -> CGFloat {
			switch permissionType {
				case .appUsage:
					return heighOfContinueButtonRow
				case .blank:
					return UITableView.automaticDimension
				default:
					return heightOfPermissionRow
			}
		}
	
		static private var heightOfPermissionRow: CGFloat {
			switch screenSize {
				case .small:
					return 170
				case .medium, .plus:
					return 170
				case .large, .modern, .max, .madMax:
					return 170
			}
		}
		
		static private var heighOfContinueButtonRow: CGFloat {
			switch screenSize {
				case .small:
					return 85
				case .medium, .plus:
					return 90
				case .large, .modern, .max, .madMax:
					return 100
			}
		}
		
		static var thumbnailDimensions: CGFloat {
			switch screenSize {
				case .small:
					return 30
				case .medium, .plus, .large:
					return 50
				case .modern, .max, .madMax:
					return 50
			}
		}
		
		static var buttonWidth: CGFloat {
			switch screenSize {
				case .small:
					return 60
				case .medium, .plus, .large:
					return 80
				case .modern, .max, .madMax:
					return 80
			}
		}
	}
}
