////
////  TemproraryClassMethodsCellBlock.swift
////  ECleaner
////
////  Created by alexey sorochan on 20.11.2021.
////
//
//import Foundation
//import UIKit
//
//
//
//
//open class MonthYearPickerView: UIControl {
//
//
////	lazy private var pickerView: UIPickerView = {
////
////		let pickerView = UIPickerView(frame: self.bounds)
////		pickerView.dataSource = self
////		pickerView.delegate = self
////		pickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////		pickerView.backgroundColor = .clear
////		pickerView.layoutIfNeeded()
////
////		let centerLineView = UIView()
////
////
////
////		centerLineView.frame = CGRect(x: pickerView.center.x, y: 0, width: 3, height: pickerView.frame.height)
////
////		pickerView.addSubview(centerLineView)
//////		centerLineView.translatesAutoresizingMaskIntoConstraints = false
//////		centerLineView.centerXAnchor.constraint(equalTo: pickerView.centerXAnchor).isActive = true
////////		centerLineView.topAnchor.constraint(equalTo: pickerView.topAnchor).isActive = true
//////		centerLineView.centerYAnchor.constraint(equalTo: pickerView.centerYAnchor).isActive = true
////////		centerLineView.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor).isActive = true
//////		centerLineView.heightAnchor.constraint(equalToConstant: 500).isActive = true
//////		centerLineView.widthAnchor.constraint(equalToConstant: 3).isActive = true
//////		centerLineView.layoutIfNeeded()
////
////		let grayScaleLayer = CALayer()
////		grayScaleLayer.frame =  CGRect(x: 0, y: 0, width: centerLineView.frame.width / 2, height: centerLineView.frame.height)
////		grayScaleLayer.backgroundColor = UIColor.red.cgColor
////		centerLineView.layer.insertSublayer(grayScaleLayer, at: 0)
////		let whiteScaleLayer = CALayer()
////		whiteScaleLayer.frame =  CGRect(x: centerLineView.frame.width / 2, y: 0, width: centerLineView.frame.width / 2, height: centerLineView.frame.height)
////		whiteScaleLayer.backgroundColor = UIColor.black.cgColor
////		centerLineView.layer.insertSublayer(whiteScaleLayer, at: 0)
////
//////		let gradietTopView = UIView()
////	//		let gradientBottomView = UIView()
////
////	//		line.backgroundColor = .red
////
////
////
////
////
////
////
//////		gradietTopView.frame = line.bounds
//////		gradientBottomView.frame = line.bounds
//////		gradientBottomView.backgroundColor = .clear
//////		gradietTopView.backgroundColor = .red
////
////
//////		line.addSubview(gradietTopView)
//////		line.addSubview(gradientBottomView)
//////
////
//////		var gradientMaskLayer:CAGradientLayer = CAGradientLayer()
//////		gradientMaskLayer.frame = CGRect(x: 0, y: 0, width: 3, height: line.frame.height / 2)
//////		gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
////////		[UIColor.clearColor().CGColor!, UIColor.blackColor().CGColor!]
////////		gradientMaskLayer.locations =  [0.0, 1.0]
//////		gradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//////		gradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
//////
//////		gradietTopView.layer.mask = gradientMaskLayer
//////
//////
//////
////		var gradientMaskLayer2:CAGradientLayer = CAGradientLayer()
////		gradientMaskLayer2.frame = CGRect(x: 0, y: 0, width: 3, height: centerLineView.frame.height / 3)
////		gradientMaskLayer2.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//////		[UIColor.clearColor().CGColor!, UIColor.blackColor().CGColor!]
//////		gradientMaskLayer.locations =  [0.0, 1.0]
////		gradientMaskLayer2.startPoint = CGPoint(x: 0.5, y: 0.0)
////		gradientMaskLayer2.endPoint = CGPoint(x: 0.5, y: 1.0)
////
////		centerLineView.layer.mask = gradientMaskLayer2
//////
////
//////		var gradient: CAGradientLayer = CAGradientLayer()
//////		gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor, UIColor.white.cgColor]
//////		gradient.frame = CGRect(origin: .zero, size: CGSize(width: 3, height: centerLineView.frame.height ))
//////		gradient.locations = [0, 0.5, 1.0]
//////		centerLineView.layer.insertSublayer(gradient, at: 0)
////
////
//////		var gradientMaskLayer2:CAGradientLayer = CAGradientLayer()
//////		gradientMaskLayer2.frame = line.bounds
//////		gradientMaskLayer2.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
////////		[UIColor.clearColor().CGColor!, UIColor.blackColor().CGColor!]
//////		gradientMaskLayer2.locations = [0.0, 0.15, 0.25, 0.75, 0.85, 1.0]
//////		line.layer.mask = gradientMaskLayer2
////
////
////
////		return pickerView
////	}()
//
//
//
//
//	/// if animated is YES, animate the wheels of time to display the new date
//	open func setDate(_ date: Date, animated: Bool) {
//		guard let yearRange = calendar.maximumRange(of: .year), let monthRange = calendar.maximumRange(of: .month) else {
//			return
//		}
//		let month = calendar.component(.month, from: date) - monthRange.lowerBound
//		pickerView.selectRow(month, inComponent: .month, animated: animated)
//		let year = calendar.component(.year, from: date) - yearRange.lowerBound
//		pickerView.selectRow(year, inComponent: .year, animated: animated)
//		pickerView.reloadAllComponents()
//	}
//
//	internal func isValidDate(_ date: Date) -> Bool {
//		if let minimumDate = minimumDate,
//			let maximumDate = maximumDate, calendar.compare(minimumDate, to: maximumDate, toGranularity: .month) == .orderedDescending { return true }
//		if let minimumDate = minimumDate, calendar.compare(minimumDate, to: date, toGranularity: .month) == .orderedDescending { return false }
//		if let maximumDate = maximumDate, calendar.compare(date, to: maximumDate, toGranularity: .month) == .orderedDescending { return false }
//		return true
//	}
//
//}
//
//
//extension MonthYearPickerView: UIPickerViewDelegate {
//
//	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//		var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
//		dateComponents.year = value(for: pickerView.selectedRow(inComponent: .year), representing: .year)
//		dateComponents.month = value(for: pickerView.selectedRow(inComponent: .month), representing: .month)
//		guard let date = calendar.date(from: dateComponents) else { return }
//		self.date = date
//	}
//
//}
//
//extension MonthYearPickerView: UIPickerViewDataSource {
//
//	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
//		return 2
//	}
//
//	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//		guard let component = Component(rawValue: component) else { return 0 }
//		switch component {
//		case .month:
//			return calendar.maximumRange(of: .month)?.count ?? 0
//		case .year:
//			return calendar.maximumRange(of: .year)?.count ?? 0
//		}
//	}
//
//	private func value(for row: Int, representing component: Calendar.Component) -> Int? {
//		guard let range = calendar.maximumRange(of: component) else { return nil }
//		return range.lowerBound + row
//	}
//
//	public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//
//		let attributedString = NSAttributedString(string: "hello", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
//		return attributedString
//	}
//
//
//	public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//		let label: UILabel = view as? UILabel ?? {
//			let label = UILabel()
//			if #available(iOS 10.0, *) {
//				label.font = .preferredFont(forTextStyle: .title2, compatibleWith: traitCollection)
//				label.adjustsFontForContentSizeCategory = true
//			} else {
//				label.font = .preferredFont(forTextStyle: .title2)
//			}
//
//
//			return label
//		}()
//
//		guard let component = Component(rawValue: component) else { return label }
//		var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
//
//
//		label.translatesAutoresizingMaskIntoConstraints = false
//		switch component {
//			case .month:
//				label.textAlignment = .right
//			case .year:
//				label.textAlignment = .left
//		}
//
//		switch component {
//			case .month:
//				dateComponents.month = value(for: row, representing: .month)
//				dateComponents.year = value(for: pickerView.selectedRow(inComponent: .year), representing: .year)
//			case .year:
//				dateComponents.month = value(for: pickerView.selectedRow(inComponent: .month), representing: .month)
//				dateComponents.year = value(for: row, representing: .year)
//		}
//
//		guard let date = calendar.date(from: dateComponents) else { return label }
//
//		switch component {
//			case .month:
//				label.text = monthDateFormatter.string(from: date)
////				label.setMargins(margin: -5)
//
//			case .year:
//				label.text = yearDateFormatter.string(from: date)
////				label.setMargins(margin: 10)
//		}
//
//		if #available(iOS 13.0, *) {
//			label.textColor = isValidDate(date) ? .label : .secondaryLabel
//
//
//			switch component {
//				case .month:
//					if isValidDate(date) {
//						label.rightPickerMargin(margin: 15)
//						label.font = .systemFont(ofSize: 20, weight: .bold)
//					} else {
//						label.rightPickerMargin(margin: 15)
//						label.font = .systemFont(ofSize: 5, weight: .medium)
//					}
//				case .year:
//					if isValidDate(date) {
//						label.leftPickerMargin(margin: 15)
//						label.font = .systemFont(ofSize: 20, weight: .bold)
//					} else {
//						label.leftPickerMargin(margin: 15)
//						label.font = .systemFont(ofSize: 5, weight: .medium)
//					}
//			}
//
//
//
//		} else {
//			label.textColor = isValidDate(date) ? .black : .red
//		}
//
//		return label
//	}
////}
////
////private extension UIPickerView {
////	func selectedRow(inComponent component: MonthYearPickerView.Component) -> Int {
////		selectedRow(inComponent: component.rawValue)
////	}
////
////	func selectRow(_ row: Int, inComponent component: MonthYearPickerView.Component, animated: Bool) {
////		selectRow(row, inComponent: component.rawValue, animated: animated)
////	}
////}
//
//
//extension UILabel {
//	func setMargins(margin: CGFloat = 10) {
//		if let textString = self.text {
//			var paragraphStyle = NSMutableParagraphStyle()
//			paragraphStyle.firstLineHeadIndent = margin
//			paragraphStyle.headIndent = margin
//			paragraphStyle.tailIndent = -margin
//			let attributedString = NSMutableAttributedString(string: textString)
//			attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
//			attributedText = attributedString
//		}
//	}
//
//	func leftPickerMargin(margin: CGFloat = 10) {
//		if let textString = self.text {
//			var paragraphStyle = NSMutableParagraphStyle()
//			paragraphStyle.firstLineHeadIndent = margin
//			paragraphStyle.headIndent = margin
////			paragraphStyle.tailIndent = -margin
//			paragraphStyle.alignment = .left
//			let attributedString = NSMutableAttributedString(string: textString)
//			attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
//			attributedText = attributedString
//		}
//	}
//
//	func rightPickerMargin(margin: CGFloat = 10) {
//		if let textString = self.text {
//			var paragraphStyle = NSMutableParagraphStyle()
//			paragraphStyle.tailIndent = -margin
//			paragraphStyle.alignment = .right
//			let attributedString = NSMutableAttributedString(string: textString)
//			attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
//			attributedText = attributedString
//		}
//	}
//
//
//}
//
//extension CAGradientLayer {
//	enum Point {
//		case topLeft
//		case centerLeft
//		case bottomLeft
//		case topCenter
//		case center
//		case bottomCenter
//		case topRight
//		case centerRight
//		case bottomRight
//		var point: CGPoint {
//			switch self {
//			case .topLeft:
//				return CGPoint(x: 0, y: 0)
//			case .centerLeft:
//				return CGPoint(x: 0, y: 0.5)
//			case .bottomLeft:
//				return CGPoint(x: 0, y: 1.0)
//			case .topCenter:
//				return CGPoint(x: 0.5, y: 0)
//			case .center:
//				return CGPoint(x: 0.5, y: 0.5)
//			case .bottomCenter:
//				return CGPoint(x: 0.5, y: 1.0)
//			case .topRight:
//				return CGPoint(x: 1.0, y: 0.0)
//			case .centerRight:
//				return CGPoint(x: 1.0, y: 0.5)
//			case .bottomRight:
//				return CGPoint(x: 1.0, y: 1.0)
//			}
//		}
//	}
//	convenience init(start: Point, end: Point, colors: [CGColor], type: CAGradientLayerType) {
//		self.init()
//		self.startPoint = start.point
//		self.endPoint = end.point
//		self.colors = colors
//		self.locations = (0..<colors.count).map(NSNumber.init)
//		self.type = type
//	}
//}
