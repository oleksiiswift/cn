//
//  SubscriptionSegmentControll.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.07.2022.
//

import UIKit

enum SubscriptionSegmentStatus {
	case willLoading
	case didLoad
	case disable
	case empty
}

enum SubscriptionSegmentType {
	case bordered
	case masked
}

protocol SubscriptionSegmentControllDelegate: AnyObject {
	func didChange(to subscription: Subscriptions)
}

protocol SegmentSubscriptionButtonDelegate {
	func indexSelect(index: Int)
}

class SubscriptionSegmentControll: UIView {
	
	public private(set) var selectedIndex: Int = 0
	
	public var subscriptions: [ProductStoreDesriptionModel]!
	public var segmentControlType: SubscriptionSegmentType = .bordered
	public var performWithAnimation: Bool = false

	private var stackView = UIStackView()
	private var maskedStackView = UIStackView()
	
	private var selectedView = UIView()
	private var selectedViewLeadingConstraint = NSLayoutConstraint()
	private var disabledView = UIView()
	private var activityIndicatorView = UIActivityIndicatorView()
	private var contentDisabledImageView = UIImageView()
	private var loadMessageTextLabel = UILabel()
	
	private var subscriptionButtons: [SegmentSubscriptionButton]!
	private var maskedSubscriptionButtons: [SegmentSubscriptionButton]!

	public var premiumMaskedBackgroundColor: UIColor = .red {
		didSet {
			self.setMaskedColor()
		}
	}
	
	private var viewSelectorInset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
	private var selectedLayer: CAShapeLayer!
	private var maskLayer: CALayer!
		
	weak var delegate: SubscriptionSegmentControllDelegate?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.commonInit()
	}
		
	public func setSubscription(subscriptions: [ProductStoreDesriptionModel]) {
		self.subscriptions = subscriptions
		
		self.configure()
	}
}

extension SubscriptionSegmentControll {
	
	public func setSegment(status: SubscriptionSegmentStatus) {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.3) {
				self.stackView(status: status)
				self.disabledView(status: status)
				self.setActivitiIndicator(status: status)
				self.contentDisabledImageView(status: status)
				self.selectorView(status: status)
				self.messageView(status: status)
			}
		}
	}
	
	private func stackView(status: SubscriptionSegmentStatus) {
		
		switch status {
			case .didLoad:
				self.stackView.isHidden = false
				self.maskedStackView.isHidden = self.segmentControlType == .masked ? false : true
			default:
				self.stackView.isHidden = true
				self.maskedStackView.isHidden = self.segmentControlType == .masked ? true : true
		}
	}
	
	private func disabledView(status: SubscriptionSegmentStatus) {
		
		switch status {
			case .willLoading, .didLoad:
				self.disabledView.isHidden = true
			case .empty, .disable:
				self.disabledView.isHidden = false
		}
	}
	
	private func contentDisabledImageView(status: SubscriptionSegmentStatus) {
		
		let networkImage = Images.systemElementsItems.connectionLost
		let disabledImage = Images.systemElementsItems.noContent
		
		switch status {
			case .willLoading, .didLoad:
				contentDisabledImageView.isHidden = true
			case .disable:
				contentDisabledImageView.image = networkImage
				contentDisabledImageView.isHidden = false
			case .empty:
				contentDisabledImageView.image = disabledImage
				contentDisabledImageView.isHidden = false
		}
	}
	
	private func setActivitiIndicator(status: SubscriptionSegmentStatus) {
		
		switch status {
			case .willLoading:
				self.activityIndicatorView.isHidden = false
				self.activityIndicatorView.startAnimating()
			case .didLoad, .disable, .empty:
				self.activityIndicatorView.isHidden = true
				self.activityIndicatorView.stopAnimating()
		}
	}
	
	private func selectorView(status: SubscriptionSegmentStatus) {
		
		switch status {
			case .willLoading, .disable, .empty:
				self.selectedView.removeFromSuperview()
			case .didLoad:
				self.configureSelector()
		}
	}
	
	private func messageView(status: SubscriptionSegmentStatus) {
		
		switch status {
			case .empty:
				self.loadMessageTextLabel.text = Localization.ErrorsHandler.PurchaseError.unknown
				self.loadMessageTextLabel.isHidden = false
			case .disable:
				self.loadMessageTextLabel.text =  Localization.ErrorsHandler.PurchaseError.networkError
				self.loadMessageTextLabel.isHidden = false
			default:
				self.loadMessageTextLabel.isHidden = true
		}
	}
}

extension SubscriptionSegmentControll {
	
	private func commonInit() {
	
		self.setupDisabledview()
		self.setupConnectionLostImageView()
		self.setupActivityView()
		self.setupStackView()
		self.setupMessage()
	}
	
	private func configure() {
		setupButtons()
		configureStackView()
		configureSelector()
	}
	
	private func setupDisabledview() {
		
		self.disabledView.isHidden = true
		
		let reuseView = ReuseShadowView()
		self.addSubview(self.disabledView)
		self.layoutIfNeeded()
		self.disabledView.translatesAutoresizingMaskIntoConstraints = false
		self.disabledView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
		self.disabledView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
		self.disabledView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		self.disabledView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
		self.disabledView.layoutIfNeeded()
		self.disabledView.addSubview(reuseView)
		reuseView.translatesAutoresizingMaskIntoConstraints = false
		reuseView.leadingAnchor.constraint(equalTo: self.disabledView.leadingAnchor).isActive = true
		reuseView.trailingAnchor.constraint(equalTo: self.disabledView.trailingAnchor).isActive = true
		reuseView.topAnchor.constraint(equalTo: self.disabledView.topAnchor).isActive = true
		reuseView.bottomAnchor.constraint(equalTo: self.disabledView.bottomAnchor).isActive = true
		reuseView.layoutIfNeeded()
	}
	
	private func setupConnectionLostImageView() {
		
		self.contentDisabledImageView.isHidden = true
		self.contentDisabledImageView.frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 30))
		self.disabledView.addSubview(self.contentDisabledImageView)
		self.contentDisabledImageView.translatesAutoresizingMaskIntoConstraints = false
		self.contentDisabledImageView.centerXAnchor.constraint(equalTo: self.disabledView.centerXAnchor).isActive = true
		self.contentDisabledImageView.centerYAnchor.constraint(equalTo: self.disabledView.centerYAnchor, constant: -10).isActive = true
		self.contentDisabledImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		self.contentDisabledImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
		self.contentDisabledImageView.tintColor = theme.subTitleTextColor
		self.contentDisabledImageView.contentMode = .scaleAspectFit
		self.contentDisabledImageView.layoutIfNeeded()
	}
	
	private func setupActivityView() {
		
		self.activityIndicatorView.isHidden = true
		self.addSubview(self.activityIndicatorView)
		self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		self.activityIndicatorView.widthAnchor.constraint(equalToConstant: 20).isActive = true
		self.activityIndicatorView.heightAnchor.constraint(equalToConstant: 20).isActive = true
		self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
	}
	
	private func setupStackView() {
	
		self.stackView.isHidden = true
		self.stackView.frame = self.bounds
		self.stackView.axis = .horizontal
		self.stackView.alignment = .fill
		self.stackView.distribution = .fillEqually
		
		addSubview(stackView)
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		
		self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
		self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
		self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		self.stackView.layoutIfNeeded()
		
		if segmentControlType == .masked {
			
			self.maskedStackView.isHidden = true
			self.maskedStackView.frame = self.bounds
			self.maskedStackView.axis = .horizontal
			self.maskedStackView.alignment = .fill
			self.maskedStackView.distribution = .fillEqually
			self.maskedStackView.backgroundColor = theme.backgroundColor
			
			self.addSubview(maskedStackView)
			self.maskedStackView.translatesAutoresizingMaskIntoConstraints = false
			
			self.maskedStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
			self.maskedStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
			self.maskedStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			self.maskedStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
			self.maskedStackView.layoutIfNeeded()
		}
	}
	
	private func setupMessage() {
		
		self.loadMessageTextLabel.isHidden = true
		self.addSubview(self.loadMessageTextLabel)
		self.loadMessageTextLabel.translatesAutoresizingMaskIntoConstraints = false
		
		self.loadMessageTextLabel.topAnchor.constraint(equalTo: self.contentDisabledImageView.bottomAnchor, constant: 0).isActive = true
		self.loadMessageTextLabel.centerXAnchor.constraint(equalTo: self.contentDisabledImageView.centerXAnchor).isActive = true
		self.loadMessageTextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
		self.loadMessageTextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
		self.loadMessageTextLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
		self.loadMessageTextLabel.numberOfLines = 0
		self.loadMessageTextLabel.textAlignment = .center
		self.loadMessageTextLabel.font = .systemFont(ofSize: 10, weight: .medium)
	}
}

extension SubscriptionSegmentControll: SegmentSubscriptionButtonDelegate {
	
	func setupDefaultIndex(index: Int) {
		
		self.selectedIndex = index
		let selectorPosition = (frame.width) / CGFloat(subscriptions.count) * CGFloat(index) + viewSelectorInset.left
		
		switch segmentControlType {
			case .bordered:
				self.selectedViewLeadingConstraint.constant = selectorPosition
				self.selectedView.layoutIfNeeded()
			case .masked:
				self.moveMaskedPath(to: selectorPosition, performWithAnimation: false)
				self.transformButton(at: index, animated: false)
		}
	}
	
	func indexSelect(index: Int) {
		
		let subscription = subscriptions[index]
		
		if let firstIndex = subscriptions.firstIndex(where: {$0 === subscription}) {
			let selectorPosition = getLeadingPosition(from: firstIndex)
			selectedIndex = firstIndex
			
			if let product = Subscriptions.allCases.first(where: {$0.rawValue == subscription.id}) {
				delegate?.didChange(to: product)
			}
			
			switch segmentControlType {
				case .bordered:
					
					self.selectedViewLeadingConstraint.constant = selectorPosition
					self.setNeedsLayout()
					
					UIView.animate(withDuration: 0.3) {
						self.layoutIfNeeded()
						if self.performWithAnimation {
							self.selectedView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
						}
					} completion: { _ in
						if self.performWithAnimation {
							UIView.animate(withDuration: 0.1) {
								self.selectedView.transform = .identity
							}
						}
					}
				case .masked:
					self.moveMaskedPath(to: selectorPosition, performWithAnimation: self.performWithAnimation)
					self.transformButton(at: index, animated: true)
			}
		}
	}
	
	private func transformButton(at index: Int, animated: Bool) {
	
		let duration = animated ? 0.2 : 0
		
		UIView.animate(withDuration: duration, delay: 0, options: .curveLinear) {
			self.maskedSubscriptionButtons[index].shadowView.transform = CGAffineTransform(scaleX: 1.0, y: 1.09)
		} completion: { _ in
			for (btnIndex, button) in self.maskedSubscriptionButtons.enumerated() {
				if btnIndex != index {
					button.shadowView.transform = .identity
				}
			}
		}
	}
	
	private func getLeadingPosition(from index: Int) -> CGFloat {
		return (frame.width) / CGFloat(subscriptions.count) * CGFloat(index) + viewSelectorInset.left
	}

	private func configureSelector() {
	
		guard !self.subviews.contains(where: {$0.tag == 666}) else { return }
		
		self.layoutIfNeeded()
	
		let sectionCount = CGFloat(self.subscriptions.count)
		let widthInsets = (self.viewSelectorInset.left + self.viewSelectorInset.right)
		let heithtInsets = (self.viewSelectorInset.top + self.viewSelectorInset.bottom)
		let selectorWidth = ((frame.width) / sectionCount) - widthInsets
		
		self.selectedView = UIView(frame: CGRect(x: self.viewSelectorInset.left, y: self.viewSelectorInset.top, width: selectorWidth, height: frame.height - heithtInsets))
		self.selectedView.tag = 666
		self.selectedView.backgroundColor = .clear
		
		addSubview(self.selectedView)
		
		switch segmentControlType {
			case .bordered:
				self.selectedView.translatesAutoresizingMaskIntoConstraints = false
				self.selectedView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.viewSelectorInset.top).isActive = true
				self.selectedView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.viewSelectorInset.bottom).isActive = true
				self.selectedView.widthAnchor.constraint(equalToConstant: (self.frame.width / sectionCount) - self.viewSelectorInset.left - self.viewSelectorInset.right).isActive = true
				
				selectedViewLeadingConstraint = self.selectedView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.viewSelectorInset.left)
				selectedViewLeadingConstraint.isActive = true
				selectedView.layoutIfNeeded()
			case .masked:
				self.selectedView.frame = .zero
				self.selectedView.isHidden = true
				let position = self.getLeadingPosition(from: self.selectedIndex)
				
				self.setMAsk(with: position)
		}
	}
	
	private func setMAsk(with position: CGFloat) {
		
		maskLayer = CALayer()
		maskLayer.frame = self.bounds
		selectedLayer = CAShapeLayer()
		selectedLayer.frame = CGRect(x: 0, y: 0, width: maskLayer.frame.width, height: maskLayer.frame.height)
		
		let finalPath = self.getFinalPath()
		let path = self.getMaskPath(with: position)
		
		finalPath.append(path.reversing())
		selectedLayer.path = finalPath.cgPath
		maskLayer.addSublayer(selectedLayer)
		maskedStackView.layer.mask = nil
		maskedStackView.layer.mask = maskLayer
	}
	
	private func moveMaskedPath(to position: CGFloat, performWithAnimation: Bool) {
		
		let finalPath = self.getFinalPath()
		let path = self.getMaskPath(with: position)
		
		finalPath.append(path.reversing())
		
		let anim = CABasicAnimation(keyPath: "path")
		anim.fromValue = selectedLayer.path
		anim.toValue = path.cgPath
		anim.duration = 0.3
		anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		performWithAnimation ? selectedLayer.add(anim, forKey: nil) : ()
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		selectedLayer.path = path.cgPath
		CATransaction.commit()
	}
	
	private func getFinalPath() -> UIBezierPath {
		return UIBezierPath(roundedRect: CGRect(x: 0 , y: 0, width: self.frame.size.width, height: self.frame.size.height), cornerRadius: 0)
	}
	
	private func getMaskPath(with position: CGFloat) -> UIBezierPath {
		return UIBezierPath(roundedRect: CGRect(x: position - self.viewSelectorInset.left, y: 0, width: self.frame.width / CGFloat(maskedSubscriptionButtons.count), height: self.frame.size.height), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0, height: 0))
	}
	
	public func configureSelectableGradient(width: CGFloat, colors: [UIColor], startPoint: CoordinateSide, endPoint: CoordinateSide, cornerRadius: CGFloat) {
		
		selectedView.gradientBorder(width: width,
									colors: colors,
									startPoint: .unitCoordinate(startPoint),
									endPoint: .unitCoordinate(endPoint),
									andRoundCornersWithRadius: cornerRadius)
	}

	private func setupButtons() {
		
		subscriptionButtons = [SegmentSubscriptionButton]()
		subscriptionButtons.removeAll()
		
		if let monthlyIndex = subscriptions.firstIndex(where: {$0.id == Subscriptions.month.rawValue}) {
			subscriptions.move(from: monthlyIndex, to: 0)
		}
		
		if let yearlyIndex = subscriptions.firstIndex(where: {$0.id == Subscriptions.year.rawValue}) {
			subscriptions.move(from: yearlyIndex, to: 1)
		}
		
		for (index, subscriptionModel) in subscriptions.enumerated() {
			let subscriptionButton = SegmentSubscriptionButton()
			subscriptionButton.shadowViewInset = self.viewSelectorInset
			subscriptionButton.configure(model: subscriptionModel, index: index)
			subscriptionButton.delegate = self
			subscriptionButtons.append(subscriptionButton)
		}
		
		if segmentControlType == .masked {
			
			maskedSubscriptionButtons = [SegmentSubscriptionButton]()
			maskedSubscriptionButtons.removeAll()
		
			for (index, subscriptionModel) in subscriptions.enumerated() {
				let subscriptionButton = SegmentSubscriptionButton()
				subscriptionButton.shadowView.cellBackgroundColor = theme.premiumColor
				subscriptionButton.shadowViewInset = self.viewSelectorInset
				subscriptionButton.configure(model: subscriptionModel, index: index)
				subscriptionButton.delegate = self
				maskedSubscriptionButtons.append(subscriptionButton)
			}
		}
	}
	
	private func setMaskedColor() {
		
		guard !maskedSubscriptionButtons.isEmpty else { return }
		
		maskedSubscriptionButtons.forEach {
			$0.shadowView.cellBackgroundColor = self.premiumMaskedBackgroundColor
		}
	}
	
	private func configureStackView() {
		
		self.stackView.arrangedSubviews
			.filter({$0 is SegmentSubscriptionButton})
			.forEach({$0.removeFromSuperview()})

		self.subscriptionButtons.forEach {
			self.stackView.addArrangedSubview($0)
		}
		
		if segmentControlType == .masked {
			
			self.maskedStackView.arrangedSubviews
				.filter({$0 is SegmentSubscriptionButton})
				.forEach({$0.removeFromSuperview()})
			
			self.maskedSubscriptionButtons.forEach {
				self.maskedStackView.addArrangedSubview($0)
			}
		}
	}
}

extension SubscriptionSegmentControll {
	
	public func setFont(title: UIFont, price: UIFont?, description: UIFont) {
		
		subscriptionButtons.forEach {
			$0.setupTitleFont(font: title)
			$0.setupPriceFont(font: price)
			$0.setupDescription(font: description)
		}
		
		if segmentControlType == .masked {
			
			maskedSubscriptionButtons.forEach {
				$0.setupTitleFont(font: title)
				$0.setupPriceFont(font: price)
				$0.setupDescription(font: description)
			}
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
}

// MARK: - appearance for bordered type -
extension SubscriptionSegmentControll {
	
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

// MARK: - appearance for masked type -
extension SubscriptionSegmentControll {
	
	public func setTextColorForTitle(color: UIColor, maskedColor: UIColor) {
		subscriptionButtons.forEach {
			$0.setupTitleColor(color: color)
		}
		
		maskedSubscriptionButtons.forEach {
			$0.setupTitleColor(color: maskedColor)
		}
	}
	
	public func setTextColorForSubtitle(color: UIColor, maskedColor: UIColor) {
		subscriptionButtons.forEach {
			$0.setupDescriptionColor(color: color)
		}
		
		maskedSubscriptionButtons.forEach {
			$0.setupDescriptionColor(color: maskedColor)
		}
	}
	
	
	public func setTexColorsforPrice(color: UIColor, maskedColor: UIColor) {
		subscriptionButtons.forEach {
			$0.setupPriceColor(color: color)
		}
		
		maskedSubscriptionButtons.forEach {
			$0.setupPriceColor(color: maskedColor)
		}
	}
}
