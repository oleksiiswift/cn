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
						case .medium:
							return ((U.screenWidth - 30) / 3.2) / U.ratio
						default:
							return  ((U.screenWidth - 30) / 3) / U.ratio
					}
				}
				
				static var singleCollectionScreenShotsItemSize: CGFloat {
					switch screenSize {
						case .small:
							return  ((U.screenWidth - 30) / 3) / U.ratio
						case .medium:
							return ((U.screenWidth - 30) / 3.2) / U.ratio
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
						case .medium:
							return 30
						default:
							return 35
					}
				}
				
				static var carouseCollectionViewItemSize: CGSize {
					switch screenSize {
						case .small:
							return CGSize(width: 90, height: 90)
						default:
							return CGSize(width: 100, height: 100)
					}
				}
				
				static var carouselCollectionViewLineInset: CGFloat {
					switch screenSize {
						case .small:
							return 20
						default:
							return 10
					}
				}
				
				static var bottomCarouselViewCollectionInset: CGFloat {
					return Device.isSafeAreaiPhone ? U.bottomSafeAreaHeight : 0
				}
				
				static var carouselCollectionViewHeght: CGFloat {
					switch screenSize {
						case .small:
							return 100
						default:
							return 120
					}
				}
				
				static var carouselSpacingMode: CarouselFlowLayoutSpacingMode {
					switch screenSize {
						case .small:
							return CarouselFlowLayoutSpacingMode.fixed(spacing: 0)
						case .medium:
							return CarouselFlowLayoutSpacingMode.fixed(spacing: 3)
						default:
							return CarouselFlowLayoutSpacingMode.fixed(spacing: 5)
					}
				}
				
				static var previewCollectionViewItemInset: CGFloat {
					switch screenSize {
						case .small:
							return 20
						case .medium:
							return 25
						case .plus:
							return 30
						default:
							return 50
					}
				}
			}
			
			static var bottomBarDefaultHeight: CGFloat {
				if Device.isSafeAreaiPhone {
					return 60 + U.bottomSafeAreaHeight
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
					case .medium, .plus, .large:
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
					case .medium, .plus, .large:
						return 12
					case .modern:
						return 14
					case .max:
						return 14
					case .madMax:
						return 14
				}
			}
			
			struct DropDounMenu {
				
				static var menuWidth: CGFloat {
					let defaultValue = U.screenWidth / 3
					switch screenSize {
						case .small:
							return defaultValue - 30
						case .medium:
							return defaultValue - 30
						default:
							return defaultValue - 100
					}
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
				
				static var radioButtonSize: CGFloat {
					switch screenSize {
						case .small:
							return 20
						case .medium, .plus:
							return 25
						case .large, .modern, .max, .madMax:
							return 33
					}
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
						case .large, .modern, .max:
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
						case .large, .modern, .max:
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
						case .plus, .large, .modern, .max, .madMax:
							return 170
					}
				}
				
				static var cutDatePickerContainerHeight: CGFloat {
					switch screenSize {
						case .small:
							return 70
						default:
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
			
			struct ModalControllerSettings {
				
				static var mainContainerHeight: CGFloat {
					switch screenSize {
						case .small:
							return U.screenHeight - (U.topSafeAreaHeight + 20)
						case .medium:
							return U.screenHeight - (U.topSafeAreaHeight + 60)
						case .plus:
							return U.screenHeight - (U.topSafeAreaHeight + 100)
						case .large:
							return U.screenHeight - (U.topSafeAreaHeight + 120)
						case .modern:
							return U.screenHeight - (U.topSafeAreaHeight + 150)
						case .max:
							return U.screenHeight - (U.topSafeAreaHeight + 180)
						case .madMax:
							return U.screenHeight - (U.topSafeAreaHeight + 200)
					}
				}
				
				static var bottomButtonSpaceValue: CGFloat {
					switch screenSize {
						case .small:
							return 5
						case .medium, .plus:
							return 5
						case .large:
							return 5
						case .modern:
							return 5
						case .max:
							return 5
						case .madMax:
							return 5
					}
				}
				
				static var segmentControlWidth: CGFloat {
					switch screenSize {
						case .small:
							return 100
						default:
							return 120
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



