//
//  LocationInfoView.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.08.2022.
//

import UIKit

class LocationInfoView: UIView {
	
	private var titleTextLabel = UILabel()
	private var infoTextLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupView()
		updateColors()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setupView()
		updateColors()
	}
	
	private func setupView() {
		
		titleTextLabel.textAlignment = .left
		infoTextLabel.textAlignment = .right
		
		titleTextLabel.font = FontManager.modalSettingsFont(of: .butttons)
		infoTextLabel.font = FontManager.modalSettingsFont(of: .butttons)
		
		let stackView = UIStackView(arrangedSubviews: [titleTextLabel, infoTextLabel])
		stackView.frame = self.bounds
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		
		self.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
	
	public func configureView(with model: LocationDescriptionModel) {
		self.titleTextLabel.text = model.title
		self.infoTextLabel.text = model.info
		
		self.infoTextLabel.numberOfLines = model.locationInfo == .location ? 3 : 1
	}
}

extension LocationInfoView: Themeble {
	
	func updateColors() {
		titleTextLabel.textColor = theme.subTitleTextColor
		infoTextLabel.textColor = theme.titleTextColor
	}
}


