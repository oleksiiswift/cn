//
//  SubscriptionSegmentControll.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.07.2022.
//

import UIKit

protocol SubscriptionSegmentControllDelegate: AnyObject {
	func didChange(to subscription: Subscriptions)
}

protocol SegmentSubscriptionButtonDelegate {
	func indexSelect(index: Int)
}

class SubscriptionSegmentControll: UIView {
	
	public private(set) var selectedIndex: Int = 0
	
	public var subscriptions: [ProductStoreDesriptionModel]!
	
	private var selectedView: UIView!
	private var selectedViewLeadingConstraint = NSLayoutConstraint()
	
	private var subscriptionButtons: [SegmentSubscriptionButton]!
	
	private var viewSelectorInset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
	public var isAnimationEnabled: Bool = false
		
	weak var delegate: SubscriptionSegmentControllDelegate?
	
	convenience init(frame: CGRect, subscriptions: [ProductStoreDesriptionModel]) {
		self.init(frame: frame)
		
		self.subscriptions = subscriptions
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)

	}
	
	public func setSubscription(subscriptions: [ProductStoreDesriptionModel]) {
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
	
	func setupDefaultIndex(index: Int) {
		self.selectedIndex = index
		let selectorPosition = (frame.width) / CGFloat(subscriptions.count) * CGFloat(index) + viewSelectorInset.left
		selectedViewLeadingConstraint.constant = selectorPosition
		self.selectedView.layoutIfNeeded()
	}
	
	func indexSelect(index: Int) {
		
		let subscription = subscriptions[index]
		
		if let firstIndex = subscriptions.firstIndex(where: {$0 === subscription}) {
			let selectorPosition = getLeadingPosition(from: firstIndex)
			selectedIndex = firstIndex
			
			if let product = Subscriptions.allCases.first(where: {$0.rawValue == subscription.id}) {
				delegate?.didChange(to: product)
			}
			
			self.selectedViewLeadingConstraint.constant = selectorPosition
			self.setNeedsLayout()
			UIView.animate(withDuration: 0.3) {
				self.layoutIfNeeded()
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
	
	private func getLeadingPosition(from index: Int) -> CGFloat {
		return (frame.width) / CGFloat(subscriptions.count) * CGFloat(index) + viewSelectorInset.left
	}
	
	private func configure() {
		setupButtons()
		setupStackView()
		configureSelector()
	}
	
	private func configureSelector() {
		
		self.layoutIfNeeded()
		
		let sectionCount = CGFloat(self.subscriptions.count)
		let widthInsets = (self.viewSelectorInset.left + self.viewSelectorInset.right)
		let heithtInsets = (self.viewSelectorInset.top + self.viewSelectorInset.bottom)
		let selectorWidth = ((frame.width) / sectionCount) - widthInsets
		
		selectedView = UIView(frame: CGRect(x: self.viewSelectorInset.left, y: self.viewSelectorInset.top, width: selectorWidth, height: frame.height - heithtInsets))
		selectedView.backgroundColor = .clear
		addSubview(selectedView)
		selectedView.translatesAutoresizingMaskIntoConstraints = false
		selectedView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.viewSelectorInset.top).isActive = true
		selectedView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.viewSelectorInset.bottom).isActive = true
		selectedView.widthAnchor.constraint(equalToConstant: (self.frame.width / sectionCount) - self.viewSelectorInset.left - self.viewSelectorInset.right).isActive = true
		
		selectedViewLeadingConstraint = selectedView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.viewSelectorInset.left)
		selectedViewLeadingConstraint.isActive = true
		selectedView.layoutIfNeeded()
	}
	
	public func configureSelectableGradient(width: CGFloat, colors: [UIColor], startPoint: CoordinateSide, endPoint: CoordinateSide, cornerRadius: CGFloat) {
		selectedView.gradientBorder(width: width, colors: colors, startPoint: .unitCoordinate(startPoint), endPoint: .unitCoordinate(endPoint), andRoundCornersWithRadius: cornerRadius)
	}

	private func setupButtons() {
		
		subscriptionButtons = [SegmentSubscriptionButton]()
		subscriptionButtons.removeAll()
		
		subviews.forEach({$0.removeFromSuperview()})
		
		for (index, subscriptionModel) in subscriptions.enumerated() {
			let subscriptionButton = SegmentSubscriptionButton()
			subscriptionButton.shadowViewInset = self.viewSelectorInset
			subscriptionButton.configure(model: subscriptionModel, index: index)
			subscriptionButton.delegate = self
			subscriptionButtons.append(subscriptionButton)
		}
	}
	
	private func setupStackView() {
		
		let stackView = UIStackView(arrangedSubviews: subscriptionButtons)
		stackView.frame = self.bounds
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		
		self.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
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
		
		switch Screen.size {
				
			case .small:
				descriptionTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15)
			case .medium:
				descriptionTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 25, bottom: 10, right: 25)
			case .plus:
				descriptionTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 25, bottom: 10, right: 25)
			case .large:
				descriptionTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 25, bottom: 10, right: 25)
			case .modern:
				descriptionTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 25, bottom: 10, right: 25)
			case .max:
				descriptionTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 25, bottom: 10, right: 25)
			case .madMax:
				descriptionTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 25, bottom: 10, right: 25)
		}
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
		self.gradientSetup()
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
		self.gradientSetup()
	}
	
	public func gradientSetup() {
		
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
	
	public func configure(model: ProductStoreDesriptionModel, index: Int) {
		
		self.index = index
		self.titleTextLabel.text = model.productName.uppercased()
		self.priceTextLabel.text = model.productPrice + "\n" + model.productPeriod
		self.descriptionTextLabel.text = model.description
	}
	
	@objc func segmentDidSelect() {
		delegate?.indexSelect(index: self.index)
	}
}
