//
//  Colors.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit
import SwiftMessages

enum Theme: Int {
    case light
    case dark
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
            case .light:
                return .darkContent
            case .dark:
                return .lightContent
        }
    }
    
//    MARK: - backgroud colors -
    
    var backgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E3E8F1")
            case .dark:
                return UIColor().colorFromHexString("E3E8F1")
        }
    }
    
    var navigationBarBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E3E8F1")
            case .dark :
                return UIColor().colorFromHexString("E3E8F1")
        }
    }
    
    var cellBackGroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("ECF0F6")
            case .dark :
                return UIColor().colorFromHexString("ECF0F6")
        }
    }
	
	var cellShadowBackgroundColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("ADB9CA")
			case .dark :
				return UIColor().colorFromHexString("ADB9CA")
		}
	}
    
    var innerBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E1E8F0")
            case .dark:
                return UIColor().colorFromHexString("E1E8F0")
        }
    }
    
    var separatorMainColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("D8DEE9")
            case .dark :
                return UIColor().colorFromHexString("D8DEE9")
        }
    }

    var separatorHelperColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F5F9FF")
            case .dark :
                return UIColor().colorFromHexString("F5F9FF")
        }
    }
    
    var primaryButtonBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E9EFF2")
            case .dark :
                return UIColor().colorFromHexString("E9EFF2")
        }
    }
	
    var dropDownMenuBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F3F7FD")
            case .dark :
                return UIColor().colorFromHexString("F3F7FD")
        }
    }
    
    var contacSectionIndexColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("30C08F")
            case .dark :
                return UIColor().colorFromHexString("30C08F")
        }
    }
    
    var shareViewButtonsColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FF9500")
            case .dark :
                return UIColor().colorFromHexString("FF9500")
        }
    }
    
    var deleteViewButtonsColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("D94B43")
            case .dark :
                return UIColor().colorFromHexString("D94B43")
        }
    }
    
    var alertProgressBackgroundColor: UIColor {
        switch self {
            case .light:
				return UIColor().colorFromHexString("586778").withAlphaComponent(0.4)
            case .dark :
                return UIColor().colorFromHexString("586778")
        }
    }
    
    var alertProgressBorderColor: UIColor {
        switch self {
            case .light:
				return UIColor().colorFromHexString("373E44").withAlphaComponent(0.4)
            case .dark :
                return UIColor().colorFromHexString("373E44")
        }
    }
    
    var progressBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("DFE6F1")
            case .dark:
                return UIColor().colorFromHexString("DFE6F1")
        }
    }
	
	var msximumSliderkColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("E9EFF2")
			case .dark :
				return UIColor().colorFromHexString("E9EFF2")
		}
	}
	
	var minimumSliderColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("3677FF").withAlphaComponent(0.3)
			case .dark :
				return UIColor().colorFromHexString("3677FF").withAlphaComponent(0.3)
		}
	}
	
	var maximumSliderTrackColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("4592FF").withAlphaComponent(0.3)
			case .dark :
				return UIColor().colorFromHexString("4592FF").withAlphaComponent(0.3)
		}
	}
	
	
	var activeButtonBackgroundColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("ECF0F6")
			case .dark :
				return UIColor().colorFromHexString("ECF0F6")
		}
	}
    
    var actionTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FF3B30")
            case .dark:
                return UIColor().colorFromHexString("FF3B30")
        }
    }
    
//    MARK: - shadow colors -
    
    var topShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FFFFFF")
            case .dark :
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
    
    var sideShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("c2c8d3")
            case .dark :
                return UIColor().colorFromHexString("D8DFEB")
        }
    }
    
    var bottomShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("A4B5C4")
            case .dark :
                return UIColor().colorFromHexString("A4B5C4")
        }
    }
    
    var primaryButtonTopShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FFFFFF")
            case .dark :
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
    
    var primaryButtonBottomShadowColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("D1DAE8")
            case .dark :
                return UIColor().colorFromHexString("D1DAE8")
        }
    }
	
	var secondaryMasterBackgroundShadowColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("E7EDF4")
			case .dark :
				return UIColor().colorFromHexString("E7EDF4")
		}
	}

//      MARK: - accent tint colors -
        
    var contactsTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("1AC18E")
            case .dark :
                return UIColor().colorFromHexString("1AC18E")
        }
    }
    
    var videosTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("418CFF")
            case .dark :
                return UIColor().colorFromHexString("418CFF")
        }
    }
    
    var photoTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F07378")
            case .dark :
                return UIColor().colorFromHexString("F07378")
        }
    }
	
	
	var videoTopGradientColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("5E92FF")
			case .dark :
				return UIColor().colorFromHexString("5E92FF")
		}
	}
	
	var videoBottomGradientColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("2AB6FF")
			case .dark :
				return UIColor().colorFromHexString("2AB6FF")
		}
	}
	
	var photoTopGradientColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("FF7B93")
			case .dark :
				return UIColor().colorFromHexString("FF7B93")
		}
	}
	
	var photoBottomGradientColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("FF934C")
			case .dark :
				return UIColor().colorFromHexString("FF934C")
		}
	}
	
	var contactTopGradientColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("16C08A")
			case .dark :
				return UIColor().colorFromHexString("16C08A")
		}
	}
	
	var contactBottomGradientColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("43C9BB")
			case .dark :
				return UIColor().colorFromHexString("43C9BB")
		}
	}

    var defaulTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("418CFF")
            case .dark :
                return UIColor().colorFromHexString("418CFF")
        }
    }
    
    var activeTitleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FFFFFF")
            case .dark:
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
	
	var contentTypeTintColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("FFFFFF")
			case .dark:
				return UIColor().colorFromHexString("FFFFFF")
		}
	}
    
//    MARK: - title and subtitle colors -
    
    var titleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("374058")
            case .dark:
                return UIColor().colorFromHexString("374058")
        }
    }
	
	var subTitleTextColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("374058").withAlphaComponent(0.5)
			case .dark:
				return UIColor().colorFromHexString("374058").withAlphaComponent(0.5)
		}
	}
	
	var navigationBarTextColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("4F4F4F")
			case .dark:
				return UIColor().colorFromHexString("4F4F4F")
		}
	}
    
    var sectionTitleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("8D93A4")
            case .dark:
                return UIColor().colorFromHexString("8F97A7")
        }
    }
	
	var tintColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("4F4F4F")
			case .dark:
				return UIColor().colorFromHexString("4F4F4F")
		}
	}
    
    var secondaryTintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("BCC4D5")
            case .dark:
                return UIColor().colorFromHexString("BCC4D5")
        }
    }
	
	var activeLinkTitleTextColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("3587E3")
			case .dark:
				return UIColor().colorFromHexString("FFFFFF")
		}
	}
	
	var helperTitleTextColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("8D94A5")
			case .dark:
				return UIColor().colorFromHexString("8D94A5")
		}
	}
    
	var sliderUntrackBackgroundColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("D7DDE5")
			case .dark:
				return UIColor().colorFromHexString("D7DDE5")
		}
	}
    
	var sliderCircleBackroundColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("ECF0F6")
			case .dark:
				return UIColor().colorFromHexString("ECF0F6")
		}
	}
	
	var topShevronBackgroundColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("8E96A7")
			case .dark:
				return UIColor().colorFromHexString("8E96A7")
		}
	}

    var customRedColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FA796F")
            case .dark:
                return UIColor().colorFromHexString("FA796F")
        }
    }
    
    var contentBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F0F0F0")
            case .dark:
                return UIColor().colorFromHexString("F0F0F0")
        }
    }
    
    var accentBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F")
            case .dark:
                return UIColor().colorFromHexString("4F4F4F")
        }
    }

	var circleProgresStartingGradient: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("66CDFF")
			case .dark:
				return UIColor().colorFromHexString("66CDFF")
		}
	}
	
	var circleProgresEndingGradient: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("3677FF")
			case .dark:
				return UIColor().colorFromHexString("3677FF")
		}
	}
	
	var circleStarterGradientColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("FF845A")
			case .dark:
				return UIColor().colorFromHexString("FF845A")
		}
	}
	
	var circleEndingGradientColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("E74BCD")
			case .dark:
				return UIColor().colorFromHexString("E74BCD")
		}
	}

	var titleCircleGradientTitleColorSet: [CGColor] {
		switch self {
			case .light:
				return [UIColor().colorFromHexString("FF845A").cgColor, UIColor().colorFromHexString("E74BCD").cgColor]
			case .dark:
				return [UIColor().colorFromHexString("FF845A").cgColor, UIColor().colorFromHexString("E74BCD").cgColor]
		}
	}
	
	var deepCleanAcentColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("E74BCD")
			case .dark:
				return UIColor().colorFromHexString("E74BCD")
		}
	}
	
	
	var photoGradientStarterColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("FF91A5")
			case .dark:
				return UIColor().colorFromHexString("FF91A5")
		}
	}
	
	
	var photoGradeintEndingColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("F69352")
			case .dark:
				return UIColor().colorFromHexString("F69352")
		}
	}
	
	
	var videGradietnStarterColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("8DB1FF")
			case .dark:
				return UIColor().colorFromHexString("8DB1FF")
		}
	}
	
	var contactsGradientStarterColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("23AEA0")
			case .dark:
				return UIColor().colorFromHexString("23AEA0")
		}
	}
	
	var videoGradientEndingColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("55BFF5")
			case .dark:
				return UIColor().colorFromHexString("55BFF5")
		}
	}
	
	var contactsGradientEndingColor: UIColor {
		switch self {
			case .light:
				return UIColor().colorFromHexString("6DACD7")
			case .dark:
				return UIColor().colorFromHexString("6DACD7")
		}
	}
	
	var photoGradient: [UIColor] {
		switch self {
			case .light:
				return [photoGradientStarterColor, photoGradeintEndingColor]
			case .dark:
				return [photoGradientStarterColor, photoGradeintEndingColor]
		}
	}
	
	var videoGradient: [UIColor] {
		switch self {
			case .light:
				return [videGradietnStarterColor, videoGradientEndingColor]
			case .dark:
				return [videGradietnStarterColor, videoGradientEndingColor]
		}
	}
	
	var contactsGradient: [UIColor] {
		switch self {
			case .light:
				return [contactsGradientStarterColor, contactsGradientEndingColor]
			case .dark:
				return [contactsGradientStarterColor, contactsGradientEndingColor]
		}
	}
	
	var compressionGradient: [UIColor] {
		switch self {
			case .light:
				let startColor = UIColor().colorFromHexString("3023AE")
				let endColor = UIColor ().colorFromHexString("C86DD7")
				return [startColor, endColor]
			case .dark:
				let startColor = UIColor().colorFromHexString("3023AE")
				let endColor = UIColor ().colorFromHexString("C86DD7")
				return [startColor, endColor]
		}
	}
	
	var backupGradient: [UIColor] {
		switch self {
			case .light:
				let startColor = UIColor().colorFromHexString("23AEA0")
				let endColor = UIColor ().colorFromHexString("6DACD7")
				return [startColor, endColor]
			case .dark:
				let startColor = UIColor().colorFromHexString("23AEA0")
				let endColor = UIColor ().colorFromHexString("6DACD7")
				return [startColor, endColor]
		}
	}
	
	var onboardingButtonColors: [UIColor] {
		switch self {
			case .light:
				let startColor = UIColor().colorFromHexString("69C5FF")
				let endColor = UIColor ().colorFromHexString("5CA4FF")
				return [startColor, endColor]
			case .dark:
				let startColor = UIColor().colorFromHexString("69C5FF")
				let endColor = UIColor ().colorFromHexString("5CA4FF")
				return [startColor, endColor]
		}
	}
}

extension Theme {
	
	var permissionNotificationAccentColors: [UIColor] {
		let startColor = UIColor().colorFromHexString("FF543E")
		let endColor = UIColor ().colorFromHexString("F99C90")
		return [startColor, endColor]
	}
	
	var permissionPhotoLibraryAccentColors: [UIColor] {
		let startColor = UIColor().colorFromHexString("AEA1CE")
		let endColor = UIColor ().colorFromHexString("82BFE6")
		return [startColor, endColor]
	}
	
	var permissionContantsAccentColors: [UIColor] {
		let startColor = UIColor().colorFromHexString("C5BFB9")
		let endColor = UIColor ().colorFromHexString("E5E3DE")
		return [startColor, endColor]
	}
	
	var permissionTrackingAccentColors: [UIColor] {
		let startColor = UIColor().colorFromHexString("FFA600")
		let endColor = UIColor ().colorFromHexString("FFCE72")
		return [startColor, endColor]
	}
}

extension Theme {
	
	public func getColorsGradient(for settings: SettingsModel) -> [UIColor] {
		switch settings {
			case .premium:
				let startColor = UIColor().colorFromHexString("6773B4")
				let endColor = UIColor ().colorFromHexString("A7B3EF")
				return [startColor, endColor]
			case .largeVideos:
				let startColor = UIColor().colorFromHexString("A45C8A")
				let endColor = UIColor ().colorFromHexString("E49CCA")
				return [startColor, endColor]
			case .dataStorage:
				let startColor = UIColor().colorFromHexString("3F9094")
				let endColor = UIColor ().colorFromHexString("8BE7EB")
				return [startColor, endColor]
			case .permissions:
				let startColor = UIColor().colorFromHexString("DB4F43")
				let endColor = UIColor ().colorFromHexString("F7ADA6")
				return [startColor, endColor]
			case .restore:
				let startColor = UIColor().colorFromHexString("6773B4")
				let endColor = UIColor ().colorFromHexString("A7B3EF")
				return [startColor, endColor]
			case .support:
				let startColor = UIColor().colorFromHexString("4FAA47")
				let endColor = UIColor ().colorFromHexString("A5E79F")
				return [startColor, endColor]
			case .share:
				let startColor = UIColor().colorFromHexString("F56A0E")
				let endColor = UIColor ().colorFromHexString("FCC49F")
				return [startColor, endColor]
			case .rate:
				let startColor = UIColor().colorFromHexString("3550C1")
				let endColor = UIColor ().colorFromHexString("92A1E1")
				return [startColor, endColor]
			case .privacypolicy:
				let startColor = UIColor().colorFromHexString("F46C0C")
				let endColor = UIColor ().colorFromHexString("FCBC8F")
				return [startColor, endColor]
			case .termsOfUse:
				let startColor = UIColor().colorFromHexString("F7876F")
				let endColor = UIColor ().colorFromHexString("FFCFC5")
				return [startColor, endColor]
			case .videoCompress:
				let startColor = UIColor().colorFromHexString("FFA600")
				let endColor = UIColor ().colorFromHexString("FFCE72")
				return [startColor, endColor]
		}
	}
}
