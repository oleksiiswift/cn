//
//  ContentBannerInfoModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.05.2022.
//

import Foundation

class ContentBannerInfoModel {
	
	var info: [PhotoMediaType: BannerInfo]
	
	init(info: [PhotoMediaType: BannerInfo]) {
		self.info = info
	}
}

class BannerInfo {
	
	var infoImage: UIImage
	var title: String
	var subtitle: String
	var descriptionTitle: String
	var descriptionFirstPartSubtitle: String
	var descriptionSecondPartSubtitle: String
	var helperImage: UIImage
	var gradientColors: [UIColor]
	
	init(infoImage: UIImage, title: String, subtitle: String, descriptionTitle: String, descriptitionFirstPartSubtitle: String, descriptionSecondPartSubtitle: String, helperImage: UIImage, gradientColors: [UIColor]) {
		self.infoImage = infoImage
		self.title = title
		self.subtitle = subtitle
		self.descriptionTitle = descriptionTitle
		self.descriptionFirstPartSubtitle = descriptitionFirstPartSubtitle
		self.descriptionSecondPartSubtitle = descriptionSecondPartSubtitle
		self.helperImage = helperImage
		self.gradientColors = gradientColors
	}
}
