//
//  CompressingInfoViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.04.2022.
//

import UIKit

class CompressingInfoViewController: UIViewController {
	
	private var informationView = UIView()
	private var titleTextLabel = UILabel()
	private var descriptionTextLabel = UILabel()
	private var dimmerView = UIView(frame: CGRect(x: 0, y: 0, width: U.screenWidth, height: U.screenHeight))
	
	public var compressingSection: CustomCompressionSection = .none
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .popover
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		
		self.view = informationView
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupUI()
		updateColors()
		addDimmerView()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		removeDimmerView()
	}
}

extension CompressingInfoViewController {
	
	func addDimmerView() {
		
		dimmerView.backgroundColor = .black.withAlphaComponent(0.3)
		let windows: [UIWindow] = UIApplication.shared.windows
		let firstWindow: UIWindow = windows[0]
		
		firstWindow.addSubview(dimmerView)
		firstWindow.bringSubviewToFront(dimmerView)
	}
	
	func removeDimmerView() {
		UIView.animate(withDuration: 0.2) {
			self.dimmerView.removeFromSuperview()
		} completion: { _ in }
	}
	
	@objc func dissmiss() {
		self.dismiss(animated: true)
	}
}

extension CompressingInfoViewController: Themeble {
	
	private func setupUI() {
		
		let dissmissGestire = UITapGestureRecognizer(target: self, action: #selector(dissmiss))
		informationView.addGestureRecognizer(dissmissGestire)
		
		titleTextLabel.font = .systemFont(ofSize: 12, weight: .semibold)
		descriptionTextLabel.font = .systemFont(ofSize: 10, weight: .medium)
		
		titleTextLabel.text = compressingSection.name
		descriptionTextLabel.text = compressingSection.description
		descriptionTextLabel.numberOfLines = 0
		descriptionTextLabel.lineBreakMode = .byWordWrapping
	
		informationView.addSubview(titleTextLabel)
		titleTextLabel.translatesAutoresizingMaskIntoConstraints = false
		titleTextLabel.leadingAnchor.constraint(equalTo: informationView.leadingAnchor, constant: 10).isActive = true
		titleTextLabel.trailingAnchor.constraint(equalTo: informationView.trailingAnchor, constant: -10).isActive = true
		titleTextLabel.topAnchor.constraint(equalTo: informationView.topAnchor, constant: 7).isActive = true
		titleTextLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
		
		
		informationView.addSubview(descriptionTextLabel)
		descriptionTextLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionTextLabel.widthAnchor.constraint(equalToConstant: U.screenWidth - 120).isActive = true
		descriptionTextLabel.leadingAnchor.constraint(equalTo: informationView.leadingAnchor, constant: 10).isActive = true
		descriptionTextLabel.trailingAnchor.constraint(equalTo: informationView.trailingAnchor, constant: -10).isActive = true
		descriptionTextLabel.topAnchor.constraint(equalTo: titleTextLabel.topAnchor, constant: 5).isActive = true
		descriptionTextLabel.bottomAnchor.constraint(equalTo: informationView.bottomAnchor, constant: 0).isActive = true
		
		titleTextLabel.layoutIfNeeded()
		descriptionTextLabel.layoutIfNeeded()
		self.view.layoutIfNeeded()
		
		let offset = 27 + 15 * CGFloat(descriptionTextLabel.maxNumberOfLines)
		preferredContentSize = CGSize(width: U.screenWidth - 100, height: offset)
	}
	
	func updateColors() {
		
		titleTextLabel.textColor = theme.titleTextColor
		descriptionTextLabel.textColor = theme.titleTextColor
		informationView.backgroundColor = theme.cellBackGroundColor
	}
}


