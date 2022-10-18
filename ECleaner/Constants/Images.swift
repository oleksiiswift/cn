//
//  Images.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import UIKit

typealias I = Images
struct Images {

    static let blank = UIImage(named: "")
	static let applicationIcoon = UIImage(named: "appShareIcon")
    
    struct mainStaticItems {
        static let clean = UIImage(named: "clean")!
        static let photo = UIImage(named: "photo")!
        static let video =  UIImage(named: "video")!
        static let contacts = UIImage(named: "contact")!
    }
    
    struct systemItems {
        
        struct navigationBarItems {
            static let dissmiss = UIImage(named: "dissmiss")!
            static let back = UIImage(named: "shevronArrowLeft")!
            static let forward = UIImage(named: "shevronArrowRight")!
            static let premium = UIImage(named: "premium")!
            static let settings = UIImage(named: "settings")!
            static let burgerDots = UIImage(named: "burgerDots")!
            static let magicBrush = UIImage(systemName: "paintbrush.fill")!
			static let stopMagic = UIImage(named: "stopMagicSearch")!
			static let sort = UIImage(systemName: "arrow.up.arrow.down")!
        }
        
        struct selectItems {
            static let roundedCheckMark = UIImage(named: "roundedCheckmark")!
            static let circleMark = UIImage(named: "circle")!
			static let checkBox = UIImage(named: "check")!
        }
        
        struct defaultItems {
            static let share = UIImage(named: "share")!
            static let buttonShare = UIImage(named: "defaultButtonShare")!
            static let merge = UIImage(named: "mergeArrowTop")!
            static let delete = UIImage(named: "deleteItem")!
			static let recover = UIImage(named: "recoverTrashBin")!
            static let refresh = UIImage(named: "circleArrow")!
            static let deepClean = UIImage(named: "deepClean")!
            static let refreshFull = UIImage(named: "circleRoundedArrows")!
			static let onViewPlayButton = UIImage(named: "playTransparentItem")!
			static let trashBin = UIImage(named: "defaultTrashBin")!
            static let star = UIImage(named: "starItem")!
            static let arrowUP = UIImage(named: "arrowUpDown")!
			static let compress = UIImage(named: "compressItem")!
			static let info = UIImage(named: "infoItem")!
			static let arrowLeft = UIImage(named: "arrowLeftItem")!
			static let circleArrow = UIImage(named: "circleRoundedThin")!
			static let save = UIImage(systemName: "tray.and.arrow.up")!
			static let xmark = UIImage(systemName: "xmark")!
        }
		
		struct helpersItems {
			static let segmentDotSlider = UIImage(named: "sigmentSlider")
		}
        
        struct backroundStaticItems {
            static let spreadBackground = UIImage(named: "dateViewBackground")!
        }
    }
    
    struct personalisation {
        
        struct contacts {
            static let sectionSelect = UIImage(named: "contactSectionSelect")!
            static let selectContact = UIImage(named: "selectContact")
            static let deselectContact = UIImage(named: "deselectContact")
            static let deleteContact = UIImage(named: "contactWithCross")!
            static let mergeContact = UIImage(named: "mergeContactArrowRight")!
            static let contactPhoto = UIImage(named: "contactWithoutPhoto")!
            static let processingThumb = UIImage(named: "contactsProcessingEmptyItem")!
            static let unavailibleThumb = UIImage(named: "contactsThumbUnselect")!
			static let bannerHelperImage = UIImage(named: "cloudSyncConatactItem")!
			static let cloud = UIImage(named: "cloud-sync")
			static let archiveBox = UIImage(systemName: "archivebox")!
			static let processing = UIImage(systemName: "person.3")!
        }
        
        struct photo {
            static let processingThumb = UIImage(named: "photoProcessingEmptyItem")!
            static let unavailibleThumb = UIImage(named: "photoThumbUnselect")!
			static let checkmark = UIImage(named: "photoSectionSelect")!
			static let locationRemove = UIImage(named: "delete-loc")!
        }
        
        struct video {
            static let processingThumb = UIImage(named: "videoProcessingEmptyItem")!
            static let unavailibleThumb = UIImage(named: "videoThumbUnselect")!
			static let checkmark = UIImage(named: "videoSectionSelect")!
			static let unselected = UIImage(named: "unselectedRoundedItem")!
			static let selected = UIImage(named: "selectedRoundedItem")!
			static let reset = UIImage(named: "resetBackwardItem")!
			static let bannerHelperImage = UIImage(named: "compressZipItem")!
        }
    }
	
	struct setting {
		static let largeVideo = UIImage(named: "photoProcessingEmptyItem")!
		static let storage = UIImage(named: "photoProcessingEmptyItem")!
		static let permission = UIImage(named: "photoProcessingEmptyItem")!
		static let restore = UIImage(named: "photoProcessingEmptyItem")!
		static let support = UIImage(named: "photoProcessingEmptyItem")!
		static let share = UIImage(named: "photoProcessingEmptyItem")!
		static let rate = UIImage(named: "photoProcessingEmptyItem")!
		static let privacy = UIImage(named: "photoProcessingEmptyItem")!
		static let terms = UIImage(named: "photoProcessingEmptyItem")!
	}
	
	struct player {
		static let play = UIImage(named: "playButtonItem")!
		static let pause = UIImage(named: "pauseItem")!
		static let sliderThumb = UIImage(named: "sliderThumbItem")!
		static let templatePlay = UIImage(named: "tePlayButtonItem")!
		static let templatePause = UIImage(named: "tePauseItem")!
	}

    struct navigationItems {
        static let elipseBurger = UIImage(systemName: "ellipsis.circle.fill")
        static let leftShevronBack = UIImage(systemName: "chevron.left")
    }
    
    struct systemElementsItems {
        static let crissCross = UIImage(systemName: "xmark.circle.fill")
        static let checkBoxIsChecked = UIImage(systemName: "checkmark.square")
        static let circleBox = UIImage(systemName: "circle")
        static let circleCheckBox = UIImage(systemName: "checkmark.circle.fill")
        static let tileView = UIImage(systemName: "square.grid.2x2.fill")
        static let sliderView = UIImage(named: "sliderItem")
		static let trashBtn = UIImage(systemName: "trash")
		static let share = UIImage(systemName: "square.and.arrow.up")
		static let arrowRight = UIImage(systemName: "arrow.right")!
		static let connectionLost = UIImage(systemName: "wifi.slash")
		static let noContent = UIImage(systemName: "exclamationmark.circle")
		static let persons = UIImage(systemName: "person.2.square.stack")!
		static let person = UIImage(systemName: "person.circle")!
	}
	
	struct onboarding {
		static let photo = UIImage(named: "photoonboarding")!
		static let video = UIImage(named: "videoonboarding")!
		static let contacts = UIImage(named: "contactsonboarding")!
	}
	
	struct onboardingAnimation {
		
		static let photo = "photo"
		static let video = "video"
		static let contacts = "contacts"
	}
	
	struct subsctiption {
		
		public static var rocket = UIImage(named: "rocket")
		public static var crown = UIImage(named: "crown")
		public static var rocketPocket = UIImage(named: "rocketPocket")
		public static var colorRocket = UIImage(named: "colorRocket")
		public static var flyingRocket = UIImage(named: "rocketFlyingPocket")
		
		public static func getFeaturesImages(for type: PremiumFeature) -> UIImage {
			switch type {
				case .deepClean:
					return UIImage(named: "deepCleanFeature")!
				case .multiselect:
					return UIImage(named: "multiselectFeature")!
				case .compression:
					return UIImage(named: "videoFeature")!
				case .location:
					return UIImage(named: "locationFeature")!
			}
		}
	}
	
	struct location {
		
		public static var map = UIImage(systemName: "map")!
		public static var grid = UIImage(systemName: "rectangle.3.offgrid")!
		public static var slashPin = UIImage(systemName: "mappin.slash")!
		public static var pin = UIImage(systemName: "mappin.and.ellipse")!
	}
}

extension Images {
	
	public func getSettingsImages(for settings: SettingsModel) -> UIImage {
		switch settings {
			case .premium:
				return UIImage()
			case .largeVideos:
				return UIImage(systemName: "video")!
			case .dataStorage:
				return UIImage(systemName: "tray.2")!
			case .permissions:
				return UIImage(systemName: "hand.raised")!
			case .restore:
				return UIImage(systemName: "purchased")!
			case .lifetime:
				if #available(iOS 14.0, *) {
					return UIImage(systemName: "crown")!
				} else {
					return UIImage(named: "crownLower")!
				}
			case .support:
				return UIImage(systemName: "captions.bubble")!
			case .share:
				return UIImage(systemName: "square.and.arrow.up.on.square")!
			case .rate:
				if #available(iOS 15.0, *) {
					return UIImage(systemName: "star.bubble")!
				} else {
					return UIImage(systemName: "star")!
				}
			case .privacypolicy:
				if #available(iOS 15.0, *) {
					return UIImage(systemName: "list.bullet.rectangle.portrait")!
				} else {
					return UIImage(systemName: "doc.text")!
				}
			case .termsOfUse:
				return UIImage(systemName: "doc.on.clipboard")!
			case .videoCompress:
				return UIImage(systemName: "tray.2")!
		}
	}
}

extension Images {
	
	public static func getPermissionImage(for permission: Permission.PermissionType) -> UIImage {
		switch permission {
			case .notification:
				return UIImage(systemName: "app.badge.fill")!
			case .photolibrary:
				if #available(iOS 15.0, *) {
					return UIImage(systemName: "circle.hexagonpath.fill")!
				} else {
					return UIImage(systemName: "photo.fill")!
				}
			case .contacts:
				return UIImage(systemName: "person.crop.square")!
			case .tracking:
				if #available(iOS 15.0, *) {
					return UIImage(systemName: "app.connected.to.app.below.fill")!
				} else {
					return UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")!
				}
			default:
				if #available(iOS 15.0, *) {
					return UIImage(systemName: "hand.raised.fill")!
				} else {
					return UIImage(systemName: "hand.raised.fill")!
				}
		}
	}
}

extension Images {
	
	public static func getNotificationActionSystemImages(by action: NotificationAction) -> String {
		switch action {
			case .deepClean:
				return "paintbrush"
			case .similarPhotoClean:
				return "camera.on.rectangle"
			case .duplicatedPhotoClean:
				return "photo.circle" // dup photo
			case .similiarVideoClean:
				return "video.square" // sim vid
			case .duplicatedVideoClean:
				return "film.circle" // dup vide
			case .duplicatedContactsClean:
				return "person.crop.rectangle.stack" // contacts
			case .photoScan:
				return "camera.on.rectangle"
			case .videoScan:
				return "video"
			case .contactsScan:
				return "person.text.rectangle"
			default:
				return "paintbrush"
		}
	}
}

extension Images {
	
	public static func getMenuItemImages(_ action: MenuItemType) -> UIImage {
		
		switch action {
			case .select:
				return UIImage(systemName: "checkmark.circle")!
			case .deselect:
				return UIImage(systemName: "circle")!
			case .layout:
				return UIImage(systemName: "square.grid.2x2")!
			case .share:
				return UIImage(systemName: "square.and.arrow.up")!
			case .edit:
				return UIImage(systemName: "checkmark.circle")!
			case .delete:
				return UIImage(systemName: "trash")!
			case .export:
				return UIImage(systemName: "square.and.arrow.up")!
			case .sortByDate:
				return self.getSortingImage(of: .date)
			case .sortBySize:
				return self.getSortingImage(of: .size)
			case .sortByDimension:
				return self.getSortingImage(of: .dimension)
			case .sortByEdit:
				return self.getSortingImage(of: .edit)
			case .duration:
				return self.getSortingImage(of: .duration)
		}
	}
}

extension Images {
	
	public static func getSortingImage(of type: SortingType) -> UIImage {
		switch type {
			case .date:
				return UIImage(systemName: "calendar")!
			case .size:
				return UIImage(systemName: "tray.full")!
			case .dimension:
				if #available(iOS 14.0, *) {
					return UIImage(systemName: "ruler")!
				} else {
					return UIImage(systemName: "aspectratio")!
				}
			case .edit:
				return UIImage(systemName: "pencil.and.ellipsis.rectangle")!
			case .duration:
				return UIImage(systemName: "timer")!
		}
	}
}

extension Images {
	
	struct messages {
		
		public static func getLimitExceededImage(of type: LimitAccessType, with size: CGFloat) -> UIImage? {
			
			switch type {
				case .selectPhotos:
					return "⚠️".image(of: size)
				case .selectVideo:
					return "⚠️".image(of: size)
				case .selectContact:
					return "⚠️".image(of: size)
				case .selectContactGroup:
					return "⚠️".image(of: size)
				default:
					return "🦄".image(of: size)
			}
		}
	}
}

