//
//  UIFont.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.05.2022.
//

import Foundation

extension UIFont {
	var monospacedDigitFont: UIFont {
		let fontDescriptorFeatureSettings = [[UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType, UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]]
		let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings: fontDescriptorFeatureSettings]
		let oldFontDescriptor = fontDescriptor
		let newFontDescriptor = oldFontDescriptor.addingAttributes(fontDescriptorAttributes)

		return UIFont(descriptor: newFontDescriptor, size: 0)
	}
}
