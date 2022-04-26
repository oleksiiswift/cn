//
//  Utils+UIHelper.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.04.2022.
//

import Foundation

extension Utils {
	
	struct UIHelper {
		
		struct AppDimensions {
			
			static var bottomBarDefaultHeight: CGFloat {
				if Device.isSafeAreaiPhone {
					return 80 + U.bottomSafeAreaHeight
				} else {
					switch Screen.size {
						case .small:
							return 70
						case .medium, .plus:
							return 80
						default:
							return 80 + U.bottomSafeAreaHeight
					}
				}
			}
			
			static var bottomBarButtonDefaultHeight: CGFloat {
				switch Screen.size {
					case .small:
						return 50
					default:
						return 60
				}
			}
			
			static var heightOfRowOfMediaContentType: CGFloat {
				switch Screen.size {
					case .small:
						return 85
					case .medium, .plus:
						return 90
					case .large, .modern, .max, .madMax:
						return 100
				}
			}
			
			static var mediaContentTypeCellIEdgeInset: UIEdgeInsets {
				switch Screen.size {
					case .small:
						return UIEdgeInsets(top: -20, left: 0, bottom: -20, right: 0)
					default:
						return UIEdgeInsets(top: -20, left: 0, bottom: -20, right: 0)
						
				}
			}
			
			static var heightOfTopHelperCellBanner: CGFloat {
				switch Screen.size {
					case .small:
						return 140
					default:
						return 151
				}
			}
			
			static var heightOfBottomHelperCellBanner: CGFloat {
				switch Screen.size {
					case .small:
						return 140
					default:
						return 151
				}
			}
			
			static var dateSelectableHeight: CGFloat {
				switch Screen.size {
					case .small:
						return 60
					case .medium:
						return 75
					default:
						return 85
				}
			}
			
			static var mediaContentTypeTopInset: CGFloat {
				switch Screen.size {
					case .small:
						return 5
					case .medium:
						return 15
					default:
						return 25
				}
			}
		}
		
		struct AppDefaultFontSize {
			
			static var bottomBarButtonTitleFont: UIFont {
				switch Screen.size {
					case .small:
						return .systemFont(ofSize: 14, weight: .bold)
					case .medium:
						return .systemFont(ofSize: 15.8, weight: .bold)
					default:
						return .systemFont(ofSize: 16.8, weight: .bold)
				}
			}
		}
		
		struct DeviceDimensions {
			
		}
	}
}
