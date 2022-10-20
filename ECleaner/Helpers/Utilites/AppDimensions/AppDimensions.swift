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
				case .large, .modern, .pro, .max, .madMax, .proMax:
					return 170
			}
		}
		
		static private var heighOfContinueButtonRow: CGFloat {
			switch screenSize {
				case .small:
					return 85
				case .medium, .plus:
					return 90
				case .large, .modern, .pro, .max, .madMax, .proMax:
					return 100
			}
		}
		
		static var thumbnailDimensions: CGFloat {
			switch screenSize {
				case .small:
					return 30
				case .medium, .plus, .large:
					return 50
				case .modern, .pro, .max, .madMax, .proMax:
					return 50
			}
		}
		
		static var buttonWidth: CGFloat {
			switch screenSize {
				case .small:
					return 60
				case .medium, .plus, .large:
					return 80
				case .modern, .pro, .max, .madMax, .proMax:
					return 80
			}
		}
	}
}

/// `content cells`
extension AppDimensions {
	
	struct ContenTypeCells {
		
		static var heightOfRowOfMediaContentType: CGFloat {
			switch screenSize {
				case .small:
					return 85
				case .medium, .plus:
					return 90
				case .large, .modern, .pro, .max, .madMax, .proMax:
					return 100
			}
		}
		
		static var heightOfRowOfCuttedMediaContentType: CGFloat {
			switch screenSize {
				case .small:
					return 85
				case .medium, .plus, .large:
					return 90
				case .modern, .pro, .max, .madMax, .proMax:
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
				case .modern, .pro, .max, .madMax, .proMax:
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
				case .large, .modern, .pro, .max, .madMax, .proMax:
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
				case .pro:
					return 20
				case .max:
					return 20
				case .madMax:
					return 20
				case .proMax:
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
				case .large, .pro, .modern, .max, .madMax, .proMax:
					return 33
			}
		}
		
		static var helperImageViewWidth: CGFloat {
			switch screenSize {
				case .small:
					return 28
				case .medium, .plus, .large:
					return 30
				case .modern, .pro, .max, .madMax, .proMax:
					return 33
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
	}
}

/// `collection view cell size`
extension AppDimensions {
	
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
			switch Advertisement.manager.advertisementBannerStatus {
				case .active:
					return 0
				case .hiden:
					return Device.isSafeAreaiPhone ? U.bottomSafeAreaHeight : 0
			}
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
}

/// `view controllers `

extension AppDimensions {
	
	struct DateSelectController {
		
		static var datePickerContainerHeightLower: CGFloat {
			switch screenSize {
				case .small:
					return 420
				case .medium:
					return 460
				case .plus:
					return 470
				case .large, .modern, .pro, .max:
					return 485
				case .madMax, .proMax:
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
				case .large, .modern, .pro, .max:
					return 423
				case .madMax:
					return 423
				case .proMax:
					return 423
			}
		}
		
		static var fullDatePickerContainerHeight: CGFloat {
			switch screenSize {
				case .small:
					return 150
				case .medium:
					return 160
				case .plus, .large, .modern, .pro, .max, .madMax, .proMax:
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
				case .pro:
					return 20
				case .max:
					return 20
				case .madMax:
					return 20
				case .proMax:
					return 20
					
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
	}
}

extension AppDimensions {
	
	struct ContactsController {
		
		struct Collection {
			
			static var contactsCellHeight: CGFloat {
				switch screenSize {
					case .small:
						return 70
					default:
						return 80
				}
			}
			
			static var headerHeight: CGFloat {
				switch screenSize {
					case .small:
						return 25
					default:
						return 40
				}
			}
			
			static var helperImageViewWidth: CGFloat {
				switch screenSize {
					case .small:
						return 28
					case .medium, .plus, .large:
						return 30
					case .modern, .pro, .max, .madMax, .proMax:
						return 33
				}
			}
			
			static var selectHelperImageViewWidth: CGFloat {
				switch screenSize {
					case .small:
						return 20
					case .medium, .plus, .large:
						return 25
					case .modern, .pro, .max, .madMax, .proMax:
						return 28
				}
			}
			
			static var selectableGoupAssetViewWidth: CGFloat {
				switch screenSize {
					case .small:
						return 18
					case .medium, .plus, .large:
						return 23
					case .modern, .pro, .max, .madMax, .proMax:
						return 25
				}
			}
			
			static var helperImageTrailingOffset: CGFloat {
				return 20
			}
		}
		
		struct SearchBar {
			
			static var cancelButtonWidth: CGFloat {
				switch screenSize {
					case .small:
						return 70
					case .medium:
						return 70
					case .plus, .large, .modern, .pro, .max, .madMax, .proMax:
						return 90
				}
			}
			
			static var searchBarTopInset: CGFloat {
				switch screenSize {
					case .small:
						return 50
					default:
						return 60
				}
			}
			
			static var searchBarContainerHeight: CGFloat {
				switch screenSize {
					case .small:
						return 55
					default:
						return 60
				}
			}
			
			static var searchBarHeight: CGFloat {
				switch screenSize {
					case .small:
						return 35
					default:
						return 40
				}
			}
			
			static var searchBarBottomInset: CGFloat {
				switch screenSize {
					case .small:
						return 15
					default:
						return 15
				}
			}
		}
		
		struct ExportModalController {
			
			static var controllerHeight: CGFloat {
				if Device.isSafeAreaiPhone {
					return U.screenHeight / 2
				}
				switch screenSize {
					case .small:
						return U.screenHeight / 1.8
					default:
						return U.screenHeight / 2
				}
			}
			
			static var bottomButtonViewHeight: CGFloat {
				if Device.isSafeAreaiPhone {
					return 90 + U.bottomSafeAreaHeight
				} else {
					switch screenSize {
						case .small:
							return 75
						case .medium, .plus:
							return 90
						default:
							return 100 + U.bottomSafeAreaHeight
					}
				}
			}
		}
	}
}

extension AppDimensions {
	
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
				case .pro:
					return U.screenHeight - (U.topSafeAreaHeight + 160)
				case .max:
					return U.screenHeight - (U.topSafeAreaHeight + 180)
				case .madMax:
					return U.screenHeight - (U.topSafeAreaHeight + 200)
				case .proMax:
					return U.screenHeight - (U.topSafeAreaHeight + 220)
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
				case .pro:
					return 5
				case .max:
					return 5
				case .madMax:
					return 5
				case .proMax:
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

extension AppDimensions {
		
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
					return 35
				case .medium:
					return 35
				default:
					return 40
			}
		}
		
		static var navigationBarButtonSize: CGFloat {
			switch screenSize {
				case .small:
					return 35
				case .medium:
					return 35
				default:
					return 40
			}
		}
	}
}

extension AppDimensions {
	
	struct HelperBanner {
		
		static var cornerHelperImageSize: CGFloat {
			switch screenSize {
				case .small:
					return 55
				case .medium:
					return 60
				case .large, .plus, .modern, .pro:
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
				case .large, .plus, .pro, .modern:
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
				case .pro:
					return 50
				case .max:
					return 50
				case .madMax:
					return 50
				case .proMax:
					return 50
			}
		}
	}
}

extension AppDimensions {
	
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
}

extension AppDimensions {
	
	struct CircleProgress {
		
		static var circleProgressInfoDimension: CGFloat {
			switch screenSize {
				case .small:
					return 65
				case .medium, .plus, .large:
					return 75
				case .modern:
					return 85
				case  .pro:
					return 85
				case .max:
					return 85
				case .madMax:
					return 85
				case .proMax:
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
				case .pro:
					return 14
				case .max:
					return 14
				case .madMax:
					return 14
				case .proMax:
					return 14
			}
		}
	}
}

/// `bottom button`
extension AppDimensions {
	
	struct BottomButton {
		
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
		
		static var bottomBarPrimaaryButtonImageSize: CGFloat {
			switch screenSize {
				case .small:
					return 15
				case .medium, .plus:
					return 16
				default:
					return 18
			}
		}
		
		static var bottomPrimaryButtonImageSpacing: CGFloat {
			switch screenSize {
				case .small:
					return 10
				case .medium, .plus:
					return 10
				default:
					return 10
			}
		}
	}
}

extension AppDimensions {
	
	
	struct Subscription {
		
		struct Navigation {
			
			static var leftNavigationButton: CGSize {
				switch screenSize {
					case .small:
						return CGSize(width: 30, height: 30)
					case .medium:
						return CGSize(width: 35, height: 35)
					default:
						return CGSize(width: 40, height: 40)
				}
			}
			
			static var rightNavigationButton: CGSize {
				switch screenSize {
					case .small:
						return CGSize(width: 80, height: 25)
					case .medium:
						return CGSize(width: 90, height: 30)
					default:
						return CGSize(width: 100, height: 35)
				}
			}
			
			static var bottomBarButtonDefaultHeight: CGFloat {
				switch screenSize {
					case .small:
						return 50
					case .medium:
						return 50
					case .large:
						return 50
					default:
						return 60
				}
			}
		}
		
		struct Features {
			
			static var cellSize: CGFloat {
				switch screenSize {
						
					case .small:
						return 25
					case .medium:
						return 30
					case .plus:
						return 35
					case .large:
						return 38
					case .modern:
						return 40
					case .pro:
						return 40
					case .max:
						return 40
					case .madMax:
						return 40
					case .proMax:
						return 40
				}
			}
			
			static var leadingInset: CGFloat {
				switch screenSize {
					case .large:
						return 70
					default:
						return 70
				}
			}
			
			static var thumbnailSize: CGFloat {
				switch screenSize {
					case .small:
						return 20
					case .medium:
						return 25
					case .plus:
						return 26
					case .large:
						return 26
					case .modern:
						return 27
					case .pro:
						return 27
					case .max:
						return 30
					case .madMax:
						return 30
					case .proMax:
						return 30
				}
			}
			
			static var settingsThumbnailSize: CGFloat {
				switch screenSize {
					case .small:
						return 20
					case .medium:
						return 25
					case .plus:
						return 26
					case .large:
						return 26
					case .modern:
						return 27
					case .pro:
						return 27
					case .max:
						return 27
					case .madMax:
						return 27
					case .proMax:
						return 27
				}
			}
			
			static var lifeTimeConttolerHeigh: CGFloat {
				switch screenSize {
					case .small:
						return 420
					case .medium:
						return 460
					case .plus:
						return 470
					case .large, .modern, .pro, .max:
						return 485
					case .madMax:
						return 485
					case .proMax:
						return 485
				}
			}
		}
	}
}
