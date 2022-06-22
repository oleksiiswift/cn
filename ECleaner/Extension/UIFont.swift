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


//
//extension UIFont {
//	public func withMonospacedNumbers() -> Self {
//		let monospacedFeature: [UIFontDescriptor.FeatureKey: Any]
//
//		if #available(iOS 15.0, *) {
//			monospacedFeature = [
//				.type: kNumberSpacingType,
//				.selector: kMonospacedNumbersSelector
//			]
//		} else {
//			monospacedFeature = [
//				.featureIdentifier: kNumberSpacingType,
//				.typeIdentifier: kMonospacedNumbersSelector
//			]
//		}
//
//		let descriptor = fontDescriptor.addingAttributes([
//			.featureSettings: [monospacedFeature]
//		])
//
//		return Self(descriptor: descriptor, size: 0)
//	}
//}
