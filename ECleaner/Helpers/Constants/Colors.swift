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
                return UIColor().colorFromHexString("586778")
            case .dark :
                return UIColor().colorFromHexString("586778")
        }
    }
    
    var alertProgressBorderColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("373E44")
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
}

