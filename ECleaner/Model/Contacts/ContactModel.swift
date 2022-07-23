//
//  ContactModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.07.2022.
//

import Foundation
import Contacts

enum ContactModel {
	case fullName(String)
	case thumbnailImageData(UIImage)
	case phoneNumbers(CNLabeledValue<CNPhoneNumber>)
	case emailAddresses(CNLabeledValue<NSString>)
	case urlAddresses(CNLabeledValue<NSString>)
	case action
	
	var heightForRow: CGFloat {
		switch self {
			case .thumbnailImageData(_):
				return 200
			default:
				return AppDimensions.ContenTypeCells.heightOfRowOfMediaContentType 
		}
	}
}
