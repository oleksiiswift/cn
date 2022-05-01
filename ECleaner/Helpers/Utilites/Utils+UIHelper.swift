//
//  Utils+UIHelper.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.04.2022.
//

import Foundation
import UIKit

extension Utils {
	
	struct UIHelper {
		
		struct AppDimensions {
			
			static var bottomBarDefaultHeight: CGFloat {
				if Device.isSafeAreaiPhone {
					return 70 + U.bottomSafeAreaHeight
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
						return 10
					default:
						return 15
				}
			}
			
			static var circleProgressInfoDimension: CGFloat {
				switch Screen.size {
					case .small:
						return 65
					case .medium:
						return 75
					case .plus:
						return 75
					case .large:
						return 75
					case .modern:
						return 85
					case .max:
						return 85
					case .madMax:
						return 85
				}
			}
			
			static var circleProgressInfoLineWidth: CGFloat {
				switch Screen.size {
					case .small:
						return 10
					case .medium:
						return 12
					case .plus:
						return 12
					case .large:
						return 12
					case .modern:
						return 14
					case .max:
						return 14
					case .madMax:
						return 14
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
			
			static var deepCleanCircleProgressPercentLabelFont: UIFont {
				switch Screen.size {
					case .small:
						return .systemFont(ofSize: 10, weight: .bold)
					case .medium:
						return .systemFont(ofSize: 11, weight: .bold)
					case .plus:
						return .systemFont(ofSize: 12, weight: .bold)
					case .large:
						return .systemFont(ofSize: 13, weight: .bold)
					case .modern:
						return .systemFont(ofSize: 14, weight: .bold)
					case .max:
						return .systemFont(ofSize: 15, weight: .bold)
					case .madMax:
						return .systemFont(ofSize: 15, weight: .bold)
				}
			}
			
			static var deepCleanInfoHelperTitleFont: UIFont {
				switch Screen.size {
					case .small:
						return .systemFont(ofSize: 12, weight: .bold)
					case .medium:
						return .systemFont(ofSize: 14, weight: .bold)
					case .plus:
						return .systemFont(ofSize: 16, weight: .bold)
					case .large:
						return .systemFont(ofSize: 15, weight: .bold)
					case .modern:
						return .systemFont(ofSize: 16, weight: .bold)
					case .max:
						return .systemFont(ofSize: 17, weight: .bold)
					case .madMax:
						return .systemFont(ofSize: 18, weight: .bold)
				}
			}
			
			static var deepCleanInfoHelperSubtitleFont: UIFont {
				switch Screen.size {
					case .small:
						return .systemFont(ofSize: 11, weight: .medium)
					case .medium:
						return .systemFont(ofSize: 12, weight: .medium)
					case .plus:
						return .systemFont(ofSize: 12, weight: .medium)
					case .large:
						return .systemFont(ofSize: 14, weight: .medium)
					case .modern:
						return .systemFont(ofSize: 14, weight: .medium)
					case .max:
						return .systemFont(ofSize: 14, weight: .medium)
					case .madMax:
						return .systemFont(ofSize: 15, weight: .medium)
				}
			}
			
			static var deepClentSectionHeaderTitleFont: UIFont {
				switch Screen.size {
					 case .small:
						  return .systemFont(ofSize: 12, weight: .bold)
					 case .medium:
						  return .systemFont(ofSize: 14, weight: .bold)
					 case .plus:
						  return .systemFont(ofSize: 15, weight: .bold)
					 case .large, .modern, .max, .madMax:
						  return .systemFont(ofSize: 16, weight: .bold)
				}
			}
		}
		
		struct SystemDimensions {
			
			static let statusBarHeight: CGFloat = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
			
			static let topSafeAreaInset: CGFloat = U.screenHeight < 600 ? 5 : 10
			
			static let largeTitleTopSafeAreaInset: CGFloat = U.screenHeight < 600 ? 100 : 120
			
			static let navigationBarHeight: CGFloat = 44.0 + topSafeAreaInset
			
			static let statusAndNavigationBarsHeight: CGFloat = statusBarHeight + navigationBarHeight
			
			static let advertisementHeight: CGFloat = 50
			
			static let actualScreen: CGRect = {
				var rect = mainScreen.bounds
				rect.size.height -= statusAndNavigationBarsHeight
				return rect
			}()
			
			static let tabBarHeight: CGFloat = 49.0
			
			static let toolBarHeight: CGFloat = 44.0
		}
		
		
		struct Manager {
			
			static func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
				  UIGraphicsBeginImageContext(gradientLayer.bounds.size)
				  gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
				  let image = UIGraphicsGetImageFromCurrentImageContext()
				  UIGraphicsEndImageContext()
				  return UIColor(patternImage: image!)
			}
			
			static func getGradientLayer(bounds : CGRect, colors: [CGColor]) -> CAGradientLayer{
				let gradient = CAGradientLayer()
				gradient.frame = bounds
				gradient.colors = colors

				gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
				gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
				return gradient
			}
		}
	}
}
