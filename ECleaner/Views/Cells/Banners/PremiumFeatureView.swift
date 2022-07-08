//
//  PremiumFeatureView.swift
//  ECleaner
//
//  Created by alexey sorochan on 08.07.2022.
//

import UIKit

class PremiumFeatureView: UIView {
	
	private var thumbnailView = GradientShadowView()
	private var titleTextLabel = UILabel()
	
	override init(frame: CGRect) {
	  super.init(frame: frame)
	
	  setupView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setupView()
	}

	private func setupView() {
		
		self.addSubview(thumbnailView)
		thumbnailView.translatesAutoresizingMaskIntoConstraints = false
		thumbnailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
		thumbnailView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		thumbnailView.heightAnchor.constraint(equalToConstant: 30).isActive = true
		thumbnailView.widthAnchor.constraint(equalToConstant: 30).isActive = true
		
		self.addSubview(titleTextLabel)
		titleTextLabel.translatesAutoresizingMaskIntoConstraints = false
		titleTextLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive  = true
		titleTextLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		titleTextLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		titleTextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		
		thumbnailView.layoutIfNeeded()
		thumbnailView.setNeedsLayout()
	}
	
	public func configureView(from feature: PremiumFeature) {
		
		let aproxThumbSize = AppDimensions.Subscription.Features.thumbnailSize - 13
		let imageSize = CGSize(width: aproxThumbSize, height: aproxThumbSize)

		thumbnailView.setImageWithCustomBackground(image: feature.thumbnail,
												   tintColor: theme.activeTitleTextColor,
												   size: imageSize,
												   colors: feature.thumbnailColors)
		thumbnailView.setShadowColor(for: .clear, and: .clear)
		
		var titleText: String {
			let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
			let components = feature.title.components(separatedBy: chararacterSet)
			let words = components.filter { !$0.isEmpty }
			let wordsCount = words.count
			var title = ""
			if wordsCount == 2 {
				return feature.title.replacingOccurrences(of: " ", with: "\n")
			} else if wordsCount == 3 {
				for (index, word) in words.enumerated() {
					if index == 2 {
						title.append("\n")
						title.append(word)
					} else {
						title.append(word)
						title.append(" ")
					}
				}
				return title
			}
			return title
		}
		
		titleTextLabel.text = titleText
		titleTextLabel.font = .systemFont(ofSize: 10, weight: .medium)
		titleTextLabel.textColor = theme.titleTextColor
		titleTextLabel.lineBreakMode = .byWordWrapping
		titleTextLabel.numberOfLines = 2
	}
}
