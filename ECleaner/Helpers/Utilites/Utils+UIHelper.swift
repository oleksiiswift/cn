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
		
		private static let screenSize = Screen.size
		
		struct AppDimensions {
			
			struct CollectionItemSize {
				
				static var singleCollectionScreenRecordingItemSize: CGFloat {
					switch screenSize {
						case .small:
							return  ((U.screenWidth - 30) / 3) / U.ratio
						default:
							return  ((U.screenWidth - 30) / 3) / U.ratio
					}
				}
				
				static var singleCollectionScreenShotsItemSize: CGFloat {
					switch screenSize {
						case .small:
							return  ((U.screenWidth - 30) / 3) / U.ratio
						default:
							return  ((U.screenWidth - 30) / 3) / U.ratio
					}
				}
				
				static var singleCollectionLivePhotoItemSize: CGFloat {
					switch screenSize {
						case .small:
							return  ((U.screenWidth - 30) / 4) / U.ratio
						default:
							return  ((U.screenWidth - 30) / 3) / U.ratio
					}
				}
				
				static var cellSelectRectangleSize: CGFloat {
					switch screenSize {
						case .small:
							return 25
						default:
							return 40
					}
				}
			}
			
			static var bottomBarDefaultHeight: CGFloat {
				if Device.isSafeAreaiPhone {
					return 70 + U.bottomSafeAreaHeight
				} else {
					switch screenSize {
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
				switch screenSize {
					case .small:
						return 50
					default:
						return 60
				}
			}
			
			static var mediaContentTypeCellIEdgeInset: UIEdgeInsets {
				switch screenSize {
					case .small:
						return UIEdgeInsets(top: -20, left: 0, bottom: -20, right: 0)
					default:
						return UIEdgeInsets(top: -20, left: 0, bottom: -20, right: 0)
						
				}
			}
			
			static var dateSelectableHeight: CGFloat {
				switch screenSize {
					case .small:
						return 60
					case .medium:
						return 75
					default:
						return 85
				}
			}
			
			static var circleProgressInfoDimension: CGFloat {
				switch screenSize {
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
				switch screenSize {
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
			
			struct ContenTypeCells {
				
				static var heightOfRowOfMediaContentType: CGFloat {
					switch screenSize {
						case .small:
							return 85
						case .medium, .plus:
							return 90
						case .large, .modern, .max, .madMax:
							return 100
					}
				}
				
				static var heightOfRowOfCuttedMediaContentType: CGFloat {
					switch screenSize {
						case .small:
							return 85
						case .medium, .plus, .large:
							return 90
						case .modern, .max, .madMax:
							return 100
					}
				}

				/// deep clean progress bar
				static var heightOfTopHelperCellBanner: CGFloat {
					switch screenSize {
						case .small:
							return 140
						default:
							return 151
					}
				}
			
				static var heightOfBottomHelperCellBanner: CGFloat {
					switch screenSize {
						case .small:
							return 150
						case .medium, .plus:
							return 160
						case .large:
							return 170
						case .modern, .max, .madMax:
							return 180
					}
				}
				
				static var deepCleanMediaContentTypeTopInset: CGFloat {
					switch screenSize {
						case .small:
							return 5
						case .medium:
							return 10
						default:
							return 15
					}
				}
				
				static var mediaContentTypeTopInset: CGFloat {
					switch screenSize {
						case .small:
							return 20
						case .medium:
							return 30
						case .plus:
							return 50
						case .large, .modern, .max, .madMax:
							return 40
					}
				}
				
				static var mediaContentCutTypeInset: CGFloat {
					switch screenSize {
						case .small, .medium, .plus:
							return 20
						case .large:
							return 20
						case .modern:
							return 20
						case .max:
							return 20
						case .madMax:
							return 20
					}
				}
				
				static var mediaContentBottomInset: CGFloat {
					return Device.isSafeAreaiPhone ? 40 : 20
				}
			}
			
			struct DateSelectController {
				
				static var datePickerContainerHeightLower: CGFloat {
					switch screenSize {
						case .small:
							return 420
						case .medium:
							return 460
						case .plus:
							return 470
						case .large:
							return 485
						case .modern:
							return 485
						case .max:
							return 485
						case .madMax:
							return 485
					}
				}
				
				static var datePickerContainerHeightUper: CGFloat {
					switch screenSize {
						case .small:
							return 360
						case .medium:
							return 400
						case .plus:
							return 410
						case .large:
							return 423
						case .modern:
							return 423
						case .max:
							return 423
						case .madMax:
							return 423
					}
				}
				
				static var fullDatePickerContainerHeight: CGFloat {
					switch screenSize {
						case .small:
							return 150
						case .medium:
							return 160
						case .plus:
							return 170
						case .large:
							return 170
						case .modern:
							return 170
						case .max:
							return 170
						case .madMax:
							return 170
					}
				}
				
				static var cutDatePickerContainerHeight: CGFloat {
					switch screenSize {
						case .small:
							return 70
						case .medium:
							return 75
						case .plus:
							return 75
						case .large:
							return 75
						case .modern:
							return 75
						case .max:
							return 75
						case .madMax:
							return 75
					}
				}
				
				static var bottomContainerSpacerHeight: CGFloat {
					switch screenSize {
						case .small:
							return 20
						case .medium:
							return 25
						case .plus:
							return 25
						case .large:
							return 20
						case .modern:
							return 20
						case .max:
							return 20
						case .madMax:
							return 20
					}
				}
			}
			
			struct NavigationBar {
				
					///`CUSTOM NAVIGATION BAR`
				static var navigationBarHeight: CGFloat {
					switch screenSize {
						case .small:
							return 60
						default:
							return 80
					}
				}
				
				static var startingNavigationBarButtonSize: CGFloat {
					switch screenSize {
						case .small:
							return 40
						case .medium:
							return 55
						default:
							return 50
					}
				}
				
				static var navigationBarButtonSize: CGFloat {
					switch screenSize {
						case .small:
							return 45
						case .medium:
							return 50
						default:
							return 50
					}
				}
			}
			
			struct HelperBanner {
				
				static var cornerHelperImageSize: CGFloat {
					switch screenSize {
						case .small:
							return 55
						case .medium:
							return 60
						case .large, .plus, .modern:
							return 65
						default:
							return 70
					}
				}
				
				static var offsetHelperImageSize: CGFloat {
					switch screenSize {
						case .small:
							return 60
						case .medium:
							return 70
						case .large, .plus, .modern:
							return 75
						default:
							return 80
					}
				}
				
				static var roundedImageViewSize: CGFloat {
					switch screenSize {
						case .small:
							return 40
						case .medium:
							return 45
						case .plus:
							return 45
						case .large:
							return 45
						case .modern:
							return 50
						case .max:
							return 50
						case .madMax:
							return 50
					}
				}
			}
		}
		
		struct AppDefaultFontSize {
			
			struct NavigationBar {
				
				static var navigationBarTitleFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 14, weight: .bold)
						case .medium:
							return .systemFont(ofSize: 16, weight: .bold)
						default:
							return .systemFont(ofSize: 17, weight: .bold)
					}
				}
				
				static var navigationBarButtonItemsFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 14, weight: .medium)
						case .medium:
							return .systemFont(ofSize: 16, weight: .medium)
						default:
							return .systemFont(ofSize: 17, weight: .medium)
					}
				}
			}
			
			struct PickerController {
				
				static var pickerFontSize: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 20, weight: .black)
						case .medium:
							return .systemFont(ofSize: 24, weight: .black)
						case .plus:
							return .systemFont(ofSize: 26, weight: .black)
						case .large:
							return .systemFont(ofSize: 26, weight: .black)
						case .modern:
							return .systemFont(ofSize: 26, weight: .black)
						case .max:
							return .systemFont(ofSize: 26, weight: .black)
						case .madMax:
							return .systemFont(ofSize: 26, weight: .black)
					}
				}
				
				static var buttonSubTitleFontSize: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 14, weight: .bold)
						case .medium:
							return .systemFont(ofSize: 15.8, weight: .bold)
						default:
							return .systemFont(ofSize: 16.8, weight: .bold)
					}
				}
			}
			
			struct ContentBunnerFontSize {
				
				static var titleFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 12, weight: .bold)
						case .medium:
							return .systemFont(ofSize: 14, weight: .bold)
						case .plus, .large, .modern, .max, .madMax:
							return .systemFont(ofSize: 16, weight: .bold)
					}
				}
				
				static var titleSubtitleFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 10, weight: .medium)
						case .medium:
							return .systemFont(ofSize: 12, weight: .medium)
						case .plus, .large, .modern, .max, .madMax:
							return .systemFont(ofSize: 14, weight: .medium)
					}
				}
				
				static var descriptionTitleFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 12, weight: .medium)
						case .medium:
							return .systemFont(ofSize: 14, weight: .medium)
						case .plus, .large, .modern, .max, .madMax:
							return .systemFont(ofSize: 16, weight: .medium)
					}
				}
				
				static var descriptionFirstSubtitleFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 20, weight: .heavy)
						case .medium:
							return .systemFont(ofSize: 22, weight: .heavy)
						case .plus, .large, .modern, .max, .madMax:
							return .systemFont(ofSize: 24, weight: .heavy)
					}
				}
				
				static var descriptionSecondSubtitleFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 24, weight: .heavy)
						case .medium:
							return .systemFont(ofSize: 26, weight: .heavy)
						case .plus, .large, .modern, .max, .madMax:
							return .systemFont(ofSize: 29, weight: .heavy)
					}
				}
			}
			
			static var bottomBarButtonTitleFont: UIFont {
				switch screenSize {
					case .small:
						return .systemFont(ofSize: 14, weight: .bold)
					case .medium:
						return .systemFont(ofSize: 15.8, weight: .bold)
					default:
						return .systemFont(ofSize: 16.8, weight: .bold)
				}
			}
			
			static var deepCleanCircleProgressPercentLabelFont: UIFont {
				switch screenSize {
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
				switch screenSize {
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
				switch screenSize {
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
				switch screenSize {
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
			
			struct CollectionView {
				
				 static public func getVideoDurationFontSize(of collectionType: CollectionFlowLayoutType) -> UIFont {
					
					switch collectionType {
						case .carousel:
							return self.carouselDuratationLabelFont
						case .square:
							return self.squareDuarationLabelFont
						default:
							return .systemFont(ofSize: 10, weight: .bold)
					}
				}
				
				static private var carouselDuratationLabelFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 6, weight: .medium) //<- current tested device
						case .medium:
							return .systemFont(ofSize: 7, weight: .bold)
						case .plus:
							return .systemFont(ofSize: 8, weight: .bold)
						case .large:
							return .systemFont(ofSize: 9, weight: .bold)
						case .modern:
							return .systemFont(ofSize: 9, weight: .bold)
						case .max:
							return .systemFont(ofSize: 9, weight: .bold)
						case .madMax:
							return .systemFont(ofSize: 9, weight: .bold)
					}
				}
				
				static private var squareDuarationLabelFont: UIFont {
					switch screenSize {
						case .small:
							return .systemFont(ofSize: 8, weight: .medium)
						case .medium:
							return .systemFont(ofSize: 6, weight: .medium)
						case .plus:
							return .systemFont(ofSize: 6, weight: .medium)
						case .large:
							return .systemFont(ofSize: 6, weight: .medium)
						case .modern:
							return .systemFont(ofSize: 6, weight: .medium)
						case .max:
							return .systemFont(ofSize: 6, weight: .medium)
						case .madMax:
							return .systemFont(ofSize: 6, weight: .medium)
					}
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
			
			static func getGradientLayer(bounds : CGRect, colors: [CGColor]) -> CAGradientLayer {
				let gradient = CAGradientLayer()
				gradient.frame = bounds
				gradient.colors = colors

				gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
				gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
				return gradient
			}
			
			static func getGradientLayer(bounds: CGRect, colors: [CGColor], startPoint: CAGradientPoint, endPoint: CAGradientPoint) -> CAGradientLayer {
				let gradient = CAGradientLayer()
				gradient.frame = bounds
				gradient.colors = colors
				gradient.type = .axial
				gradient.startPoint = startPoint.point
				gradient.endPoint = endPoint.point
				return gradient
			}
		}
	}
}


