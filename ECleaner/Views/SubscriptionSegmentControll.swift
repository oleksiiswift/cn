//
//  SubscriptionSegmentControll.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.07.2022.
//

import UIKit

protocol SubscriptionSegmentControllDelegate: AnyObject {
	func didChange(to subscription: Int)
}

protocol SegmentSubscriptionButtonDelegate {
	func indexSelect(index: Int)
}

struct SubscriptionButtonModel {
	
	var title: String
	var price: String
	var priceDescription: String
	var subtitle: String
	var id: Int
	
	init(title: String, price: String, priceDescription: String, subtitle: String, id: Int) {
		self.title = title
		self.price = price
		self.priceDescription = priceDescription
		self.subtitle = subtitle
		self.id = id
	}
}

class SubscriptionSegmentControll: UIView {
	
	public private(set) var selectedIndex: Int = 0
	
	private var subscriptions: [SubscriptionButtonModel]!
	
	private var selectedView: UIView!
	private var subscriptionButtons: [SegmentSubscriptionButton]!
	
	private var viewSelectorInset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
	public var isAnimationEnabled: Bool = false
		
	weak var delegate: SubscriptionSegmentControllDelegate?
	
	convenience init(frame: CGRect, subscriptions: [SubscriptionButtonModel]) {
		self.init(frame: frame)
		
		self.subscriptions = subscriptions
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)

	}
	
	public func setSubscription(subscriptions: [SubscriptionButtonModel]) {
		self.subscriptions = subscriptions
		
		configure()
	}
}

extension SubscriptionSegmentControll {
	
	public func setFont(title: UIFont, price: UIFont?, description: UIFont) {
		
		subscriptionButtons.forEach {
			$0.setupTitleFont(font: title)
			$0.setupPriceFont(font: price)
			$0.setupDescription(font: description)
		}
	}
	
	public func setTextGradientColorsforPrice(_ colors: [UIColor], font: UIFont) {
		subscriptionButtons.forEach {
			$0.setupPriceGradient(colors: colors, font: font)
		}
	}
	
	public func setTextColorForPrice(_ color: UIColor) {
		subscriptionButtons.forEach {
			$0.setupPriceColor(color: color)
		}
	}
	
	public func setTextColorForTitle(_ color: UIColor) {
		subscriptionButtons.forEach {
			$0.setupTitleColor(color: color)
		}
	}
	
	public func setTextColorForSubtitle(_ color: UIColor) {
		subscriptionButtons.forEach {
			$0.setupDescriptionColor(color: color)
		}
	}
}


extension SubscriptionSegmentControll: SegmentSubscriptionButtonDelegate {

	func indexSelect(index: Int) {
	
		for (identifier, subsciption) in subscriptions.enumerated() {
			if subsciption.id == index {
				let selectorPosition = getLeadingPosition(from: identifier)
				selectedIndex = identifier
				delegate?.didChange(to: selectedIndex)
	
				UIView.animate(withDuration: 0.3) {
					self.selectedView.frame.origin.x = selectorPosition
					if self.isAnimationEnabled {
						self.selectedView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
					}
				} completion: { _ in
					if self.isAnimationEnabled {
						UIView.animate(withDuration: 0.1) {
							self.selectedView.transform = .identity
						}
					}
				}
			}
		}
	}
	
	private func getLeadingPosition(from index: Int) -> CGFloat {
		return (frame.width) / CGFloat(subscriptions.count) * CGFloat(index) + viewSelectorInset.left
	}
	
	private func configure() {
		setupButtons()
		setupStackView()
		configureSelector()
	}
	
	private func configureSelector() {
		
		let sectionCount = CGFloat(self.subscriptions.count)
		let widthInsets = (self.viewSelectorInset.left + self.viewSelectorInset.right)
		let heithtInsets = (self.viewSelectorInset.top + self.viewSelectorInset.bottom)
		let selectorWidth = ((frame.width - 40) / sectionCount) - widthInsets
		
		selectedView = UIView(frame: CGRect(x: self.viewSelectorInset.left, y: self.viewSelectorInset.top, width: selectorWidth, height: frame.height - heithtInsets))
		selectedView.backgroundColor = .clear
		addSubview(selectedView)
	}
	
	public func configureSelectableGradient(width: CGFloat, colors: [UIColor], startPoint: CoordinateSide, endPoint: CoordinateSide, cornerRadius: CGFloat) {
		selectedView.gradientBorder(width: width, colors: colors, startPoint: .unitCoordinate(startPoint), endPoint: .unitCoordinate(endPoint), andRoundCornersWithRadius: cornerRadius)
	}

	private func setupButtons() {
		
		subscriptionButtons = [SegmentSubscriptionButton]()
		subscriptionButtons.removeAll()
		
		subviews.forEach({$0.removeFromSuperview()})
		
		for model in subscriptions {
			let subscriptionButton = SegmentSubscriptionButton()
			subscriptionButton.shadowViewInset = self.viewSelectorInset
			subscriptionButton.configure(model: model)
			subscriptionButton.delegate = self
			subscriptionButtons.append(subscriptionButton)
		}
	}
	
	private func setupStackView() {
		
		let stackView = UIStackView(arrangedSubviews: subscriptionButtons)
		
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		
		self.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
	}
}

class SegmentSubscriptionButton: UIView {
	
	private var shadowView = ReuseShadowView()
	private var segmentButton = UIButton()
	
	private var titleTextLabel = UILabel()
	private var priceTextLabel = TitleLabel()
	private var descriptionTextLabel = TitleLabel()
	
	private var gradeintColors: [UIColor] = []
	
	private var index: Int = 0
	var delegate: SegmentSubscriptionButtonDelegate?
	
	public var shadowViewInset: UIEdgeInsets = UIEdgeInsets.zero
	
	
	override init(frame: CGRect) {
	  super.init(frame: frame)
	
	  setupView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setupView()
	}

	private func setupView() {
		
		segmentButton.addTarget(self, action: #selector(segmentDidSelect), for: .touchUpInside)
		titleTextLabel.textAlignment = .center
		priceTextLabel.textAlignment = .center
		descriptionTextLabel.textAlignment = .center
		priceTextLabel.numberOfLines = 2
		descriptionTextLabel.textAlignment = .center
		descriptionTextLabel.numberOfLines = 2
		descriptionTextLabel.lineBreakMode = .byWordWrapping
		descriptionTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
	}
	
	public func setupTitleFont(font: UIFont) {
		self.titleTextLabel.font = font
	}
	
	public func setupPriceFont(font: UIFont?) {
		if let font = font {
			self.priceTextLabel.font = font
		}
	}
	
	public func setupDescription(font: UIFont) {
		self.descriptionTextLabel.font = font
	}
	
	public func setupTitleColor(color: UIColor) {
		self.titleTextLabel.textColor = color
	}
	
	public func setupPriceColor(color: UIColor) {
		self.priceTextLabel.textColor = color
	}
	
	public func setupPriceGradient(colors: [UIColor], font: UIFont) {
		self.gradeintColors = colors
		self.priceTextLabel.font = font
	}
	
	public func setupDescriptionColor(color: UIColor) {
		self.descriptionTextLabel.textColor = color
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.backgroundColor = .clear
		
		self.shadowSetup()
		self.labelsStackSetup()
		self.setupButton()
		
		if !gradeintColors.isEmpty {
			if let price = self.priceTextLabel.text, let font = self.priceTextLabel.font {
				self.priceTextLabel.layoutIfNeeded()
				self.priceTextLabel.addGradientText(string: price, with: gradeintColors, font: font)
			}
		}
	}
	
	private func setupButton() {
		segmentButton.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		self.addSubview(segmentButton)
		
		segmentButton.translatesAutoresizingMaskIntoConstraints = false
		segmentButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		segmentButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		segmentButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		segmentButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
	}
	
	private func shadowSetup() {
		
		shadowView.frame = self.bounds
		self.addSubview(shadowView)
		
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		shadowView.topAnchor.constraint(equalTo: self.topAnchor, constant: shadowViewInset.top).isActive = true
		shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -shadowViewInset.bottom).isActive = true
		shadowView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: shadowViewInset.left).isActive = true
		shadowView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:  -shadowViewInset.right).isActive = true
	}
	
	private func labelsStackSetup() {

		let stackView = UIStackView(arrangedSubviews: [titleTextLabel, priceTextLabel, descriptionTextLabel])
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		self.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		stackView.layoutIfNeeded()
	}
	
	
	public func configure(model: SubscriptionButtonModel) {
		
		self.index = model.id
		self.titleTextLabel.text = model.title.uppercased()
		self.priceTextLabel.text = model.price + "\n" + model.priceDescription
		self.descriptionTextLabel.text = model.subtitle
	}
	
	@objc func segmentDidSelect() {
		delegate?.indexSelect(index: self.index)
	}
}






