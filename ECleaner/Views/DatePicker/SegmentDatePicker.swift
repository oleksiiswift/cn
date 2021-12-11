//
//  SegmentDatePicker.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.12.2021.
//

import UIKit

enum ComponentsTextMargin {
	case left
	case right
	case centered
}

enum ComponentsTextAlign {
	case left
	case right
	case centered
}

class SegmentDatePicker: UIControl {
	
		/// `private properties`
	lazy private var datePickerView: UIPickerView = UIPickerView()
	
	private var datePickerComponents = [SegmentDatePickerComponents]()
	private var currentCalendarComponents: DateComponents {
		get {
			return (self.pickerCalendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: self.currentDate)
		}
	}

	private var pickerCalendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
	
		/// `public properties`
	public var currentDate: Date = Date()
	public var datePickerType: SegmentDatePickerType = .dateTime
	public var customDatePickerType = ""
	public let numbersOfYears: Int = 100
	
	
	public var calendarIdentifier: Calendar.Identifier = .gregorian {
		didSet {
			self.pickerCalendar = Calendar(identifier: calendarIdentifier)
			self.upodatePickerViewComponentsValues(false)
		}
	}
	
	public var pickerLocale: Locale = Locale.current {
		didSet {
			pickerCalendar.locale = self.pickerLocale
		}
	}
	
	public var minimumDate = Date.distantPast {
		didSet {
			self.validateCurrentMinimumMaximum()
		}
	}
	
	public var maximumDate = Date.distantFuture {
		didSet {
			self.validateCurrentMinimumMaximum()
		}
	}
	
	public var selectebleLowerPeriodBound: Bool = false
	
	public var delegate: SegmentDatePickerDelegate?
	
		/// `compomemts ui`
	
	public var font: UIFont = .systemFont(ofSize: 18, weight: .medium)
	public var disabledFont: UIFont = .systemFont(ofSize: 18, weight: .medium)
	public var textColor: UIColor = .black
	
	public var componentMonthMargin: ComponentsTextMargin = .centered
	public var componentMonthAlign: ComponentsTextAlign = .centered
	public var componentYearMargin: ComponentsTextMargin = .centered
	public var componentYearAlign: ComponentsTextAlign = .centered
	public var marginValue: CGFloat = 0
	
	private var disableTextColor: UIColor {
		get {
			var r : CGFloat = 0
			var g : CGFloat = 0
			var b : CGFloat = 0
			
			self.textColor.getRed(&r, green: &g, blue: &b, alpha: nil)
			
			return UIColor(red: r, green: g, blue: b, alpha: 0.35)
		}
	}
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		
		configurePicker()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		configurePicker()
	}
	
	private func configurePicker() {
		
		self.datePickerView.delegate = self
		self.datePickerView.dataSource = self
		
		self.addSubview(datePickerView)
		datePickerView.translatesAutoresizingMaskIntoConstraints = false
		datePickerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
		datePickerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
		datePickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
		datePickerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
	}
	
	public override var intrinsicContentSize : CGSize {
		return self.datePickerView.intrinsicContentSize
	}

	public override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		
		self.reloadAllComponents()
		self.setDate(self.currentDate)
	}
}

extension SegmentDatePicker {
	
	public func setCurrentDate(_ date: Date, animated: Bool) {
		self.currentDate = date
		self.updateComponents(animated)
	}
	
	private func setDate(_ date: Date) {
		self.setCurrentDate(date, animated: false)
	}
}

extension SegmentDatePicker {
	
	private func getTitleFor(_ row: Int, at component: Int) -> String {
		
		let dateComponent = self.getComponent(at: component)
		let value = self.getRowValue(for: row, at: dateComponent)
		
		if dateComponent == .month {
			return segmentPickerDateFormatter().monthSymbols[value - 1]
		} else if dateComponent == .minute || dateComponent == .hour {
			return String(format: "%02d", value)
		} else {
			return String(value)
		}
	}
	
	private func valueForDateComponent(_ component: SegmentDatePickerComponents) -> Int {
		
		switch component {
			case .year:
				return self.currentCalendarComponents.year!
			case .month:
				return self.currentCalendarComponents.month!
			case .day:
				return self.currentCalendarComponents.day!
			case .hour:
				return self.currentCalendarComponents.hour!
			case .minute:
				return self.currentCalendarComponents.minute!
			default:
				return -1
		}
	}
}

extension SegmentDatePicker {
	
	private func validateCurrentMinimumMaximum() {
		let ordering = self.minimumDate.compare(self.maximumDate)
		if ordering != .orderedAscending {
			ErrorHandler.shared.showFatalErrorAlert(.datePickerMinimumDateError) {}
		}
	}
	
	private func isRowEnabled(for index: Int, at component: SegmentDatePickerComponents) -> Bool {
		
		let rowValue = self.getRowValue(for: index, at: component)
		var components = DateComponents()
		
		components.year = 	self.currentCalendarComponents.year
		components.month =	self.currentCalendarComponents.month
		components.day = 	self.currentCalendarComponents.day
		components.hour =	self.currentCalendarComponents.hour
		components.minute = self.currentCalendarComponents.minute
		
		switch component {
			case .year:
				components.year = 	rowValue
			case .month:
				components.month = 	rowValue
			case .day:
				components.day = 	rowValue
			case .hour:
				components.hour = 	rowValue
			case .minute:
				components.minute = rowValue
			default:
				return false
		}
		
		let dateForRowAt = self.pickerCalendar.date(from: components)!
		return self.dateIsInRange(dateForRowAt)
	}
	
	private func isValid(_ value: Int, for component: SegmentDatePickerComponents) -> Bool {
		
		switch component {
			case .year:
				let numberOfDaysInMonth = self.numbersOfDays(at: self.currentCalendarComponents.month!, in: value)
				return self.currentCalendarComponents.day! <= numberOfDaysInMonth
			case .month:
				let numberOfDaysInMonth = self.numbersOfDays(at: value, in: self.currentCalendarComponents.year!)
				return self.currentCalendarComponents.day! <= numberOfDaysInMonth
			case .day:
				let numberOfDaysInMonth = self.numbersOfDays(at: self.currentCalendarComponents.month!, in: self.currentCalendarComponents.year!)
				return value <= numberOfDaysInMonth
			default:
				return true
		}
	}
	
	private func validDateValueBy(updatting component : SegmentDatePickerComponents, at value : Int) -> DateComponents {
		
		var components = self.currentCalendarComponentBy(updating: component, at: value)
		
		if !self.isValid(value, for: component) {
			switch component {
				case .month:
					components.day = self.numbersOfDays(at: value, in: components.year!)
					return components
				case .day:
					components.day = self.numbersOfDays(at: components.month!, in: components.year!)
					return components
				default:
					components.day = self.numbersOfDays(at: components.month!, in: value)
					return components
			}
		} else {
			return components
		}
	}

	private func currentCalendarComponentBy(updating component: SegmentDatePickerComponents, at value: Int) -> DateComponents {
		var components = self.currentCalendarComponents
		
		switch component {
			case .year:
				components.year = value
				return components
			case .month:
				components.month = value
				return components
			case .day:
				components.day = value
				return components
			case .hour:
				components.hour = value
				return components
			case .minute:
				components.minute = value
				return components
			default:
				return components
		}
	}
	
	public func dateIsInRange(_ date : Date) -> Bool {
		return self.minimumDate.compare(date) != ComparisonResult.orderedDescending && self.maximumDate.compare(date) != ComparisonResult.orderedAscending
	}
	
		
	private func setComponentIndex(_ component: SegmentDatePickerComponents, animated: Bool) {
		self.setIndexOfComponent(component, value: self.valueForDateComponent(component), animated: animated)
	}
	
	private func setIndexOfComponent(_ component: SegmentDatePickerComponents, value: Int, animated: Bool) {
		
		guard component != .space else { return }
		
		let pickerDateRange = self.getMaximumPickerRangeForDateComponent(component)
		let index = value - pickerDateRange.lowerBound
		var componentIndex = 0
		
		for (index, dateComponent) in self.datePickerComponents.enumerated() {
			if dateComponent == component {
				componentIndex = index
			}
		}
		
		self.datePickerView.selectRow(index, inComponent: componentIndex, animated: animated)
	}
	
	private func getMaximumPickerRangeForDateComponent(_ component: SegmentDatePickerComponents) -> Range<Int> {
				
		switch component {
			case .year:
				let currentYear = Date().getYear()
				return Range(uncheckedBounds: (lower: currentYear - numbersOfYears / 2, upper: currentYear + numbersOfYears / 2))
			case .month:
				return self.pickerCalendar.maximumRange(of: .month)!
			case .day:
				return self.pickerCalendar.maximumRange(of: .day)!
			case .hour:
				return self.pickerCalendar.maximumRange(of: .hour)!
			case .minute:
				return self.pickerCalendar.maximumRange(of: .minute)!
			default:
				return Range(uncheckedBounds: (lower: 0, upper: 0))
		}
	}
	
	private func getComponent(at index: Int) -> SegmentDatePickerComponents {
		if self.datePickerComponents.count > index {
			return self.datePickerComponents[index]
		} else {
			return SegmentDatePickerComponents.invalid
		}
	}
	
	private func getRowValue(for row: Int, at component: SegmentDatePickerComponents) -> Int {
		
		if component != .space {
			
			let calendarUnitRange = self.getMaximumPickerRangeForDateComponent(component)
			return calendarUnitRange.lowerBound + (row % (calendarUnitRange.upperBound - calendarUnitRange.lowerBound))
		} else {
			return -1
		}
	}

}

extension SegmentDatePicker {
	
	private func segmentPickerDateFormatter() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = self.pickerCalendar
		dateFormatter.locale = self.pickerLocale
		return dateFormatter
	}
}

extension SegmentDatePicker {
	
	public func reloadAllComponents() {
		self.datePickerComponents = [SegmentDatePickerComponents]()
		self.reloadComponent()
		self.datePickerView.reloadAllComponents()
	}
	
	private func reloadComponent() {
	
		var pickerFormat = self.datePickerType.rawValue
		if self.datePickerType == .custom {
			pickerFormat = self.customDatePickerType
		}
		
		pickerFormat.forEach { component in
			if let pickerDateComponent = SegmentDatePickerComponents(rawValue: component) {
				self.datePickerComponents.append(pickerDateComponent)
			}
		}
	}
	
	private func updateComponents(_ animated: Bool) {
		for (_, dateComponent) in self.datePickerComponents.enumerated() {
			self.setComponentIndex(dateComponent, animated: animated)
		}
	}
	
	private func upodatePickerViewComponentsValues(_ animated: Bool) {
		for (_, dateComponent) in self.datePickerComponents.enumerated() {
			self.setComponentIndex(dateComponent, animated: animated)
		}
	}
}

extension SegmentDatePicker {
	
	private func numbersOfDays(at month: Int, in year: Int) -> Int {
		
		var components = DateComponents()
		components.day = 1
		components.month = month
		components.year = year
		
		let calendarRange = (self.pickerCalendar as NSCalendar).range(of: .day, in: .month, for: self.pickerCalendar.date(from: components)!)
		return calendarRange.length
	}
}

extension SegmentDatePicker: UIPickerViewDataSource {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		if self.datePickerType == .custom {
			return self.customDatePickerType.count
		} else {
			return self.datePickerType.rawValue.count
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		let componentsValuesCount = self.getComponent(at: component)
		
		switch componentsValuesCount {
			case .year:
				return 100
			case .month:
				return 12
			case .day:
				return 31
			case .hour:
				return 24
			case .minute:
				return 60
			default:
				return 0
		}
	}
}

extension SegmentDatePicker: UIPickerViewDelegate {
	
	public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return font.lineHeight + 10
	}
	
	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		let datePickerComponent = self.getComponent(at: component)
		let value = self.getRowValue(for: row, at: datePickerComponent)
		let components = self.validDateValueBy(updatting: datePickerComponent, at: value)
		
		if !self.dateIsInRange(self.pickerCalendar.date(from: components)!) {
			if self.selectebleLowerPeriodBound {
				self.setCurrentDate(self.currentDate, animated: true)
			} else {
				self.setCurrentDate(Date(), animated: true)
			}
		} else {
			
			let componentsAtRow = self.currentCalendarComponentBy(updating: datePickerComponent, at: value)
			let day = components.day!
			
			if componentsAtRow.day != components.day {
				self.setIndexOfComponent(.day, value: day, animated: self.isValid(day, for: .day))
			}
			
			if componentsAtRow.month != components.month {
				self.setIndexOfComponent(.month, value: day, animated: datePickerComponent != .month)
			}
			
			if componentsAtRow.year != components.year {
				self.setIndexOfComponent(.year, value: day, animated: datePickerComponent != .year)
			}
 
			self.currentDate = self.pickerCalendar.date(from: components)!
			self.sendActions(for: .valueChanged)
		}
		
		pickerView.reloadAllComponents()
		self.delegate?.datePicker(self, didSelect: row, in: component)
	}
	
	public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		
		if #available(iOS 14.0, *) {
			
			let height: CGFloat = 0.5
			for subview in pickerView.subviews {
				if subview.frame.size.height < 60 {
					if subview.subviews.isEmpty {
						let topLineView = UIView()
						topLineView.frame = CGRect(x: 0.0, y: 0.0, width: subview.frame.size.width, height: height)
						topLineView.backgroundColor = .clear
						subview.addSubview(topLineView)
						let bottomLineView = UIView()
						bottomLineView.frame = CGRect(x: 0.0, y: subview.frame.size.height - height, width: subview.frame.size.width, height: height)
						bottomLineView.backgroundColor = .clear
						subview.addSubview(bottomLineView)
					}
				}
				subview.backgroundColor = .clear
			}
		}
		
		let label = UILabel()
		let componentAtIndex = self.getComponent(at: component)
		label.font = self.isRowEnabled(for: row, at: componentAtIndex) ? font : disabledFont
		label.textColor = textColor
		label.text = self.getTitleFor(row, at: component)
		
		let containerView = UIView()
		
		containerView.frame = CGRect(x: 0, y: 0, width: U.screenWidth / 2 - 20, height: 60)
		containerView.addSubview(label)
		label.frame = containerView.frame
		label.textAlignment = .center

		return containerView
		
					if componentAtIndex == .month {
			
						if componentMonthMargin == .centered {
							label.textAlignment = .center
						} else if componentMonthMargin == .left {
							if marginValue != 0 {
								label.leftMargin(margin: marginValue)
							} else {
								label.leftMargin()
							}
						} else if componentMonthMargin == .right {
							if marginValue != 0 {
								label.rightMargin(margin: marginValue)
							} else {
								label.rightMargin()
							}
						} else if componentMonthAlign == .left {
							label.textAlignment = .left
						} else if componentMonthAlign == .right {
							label.textAlignment = .right
						}
					} else if componentAtIndex == .year {
						if componentYearMargin == .centered {
							label.textAlignment = .center
						} else if componentYearMargin == .left {
							if marginValue != 0 {
								label.leftMargin(margin: marginValue)
							} else {
								label.leftMargin()
							}
						} else if componentYearMargin == .right {
							if marginValue != 0 {
								label.rightMargin(margin: marginValue)
							} else {
								label.rightMargin()
							}
						} else if componentYearAlign == .left {
							label.textAlignment = .left
						} else if componentYearAlign == .right {
							label.textAlignment = .right
						}
					}
		return label
	}
	
//			public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//				return U.screenWidth / 2
//			}
	
//	public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//				let widthBuffer = 25.0 + 20
////
//		let calendarComponent = self.getComponent(at: component)
//
//				let stringSizingAttributes = [NSAttributedString.Key.font : self.font]
//				var size = 0.01
////
//				if calendarComponent == .month {
//					let dateFormatter = self.segmentPickerDateFormatter()
////
////					let yearComponentSizingString = NSString(string: "0000000000")
////					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
////					// Get the length of the longest month string and set the size to it.
//					for symbol in dateFormatter.monthSymbols! {
//						let monthSize = NSString(string: symbol).size(withAttributes: stringSizingAttributes)
//////
//						size = max(size, Double(monthSize.width))
////////						size = 200
//					}
//				} else if calendarComponent == .day{
//					// Pad the day string to two digits
//					let dayComponentSizingString = NSString(string: "00")
//					size = Double(dayComponentSizingString.size(withAttributes: stringSizingAttributes).width)
//				} else if calendarComponent == .year  {
//					// Pad the year string to four digits.
//					return U.screenWidth / 2
//
//
//					let yearComponentSizingString = NSString(string: "00000000")
//					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
//
//
//				} else if calendarComponent == .hour  {
//					// Pad the year string to four digits.
//					let yearComponentSizingString = NSString(string: "00")
//					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
//				} else if calendarComponent == .minute  {
//					// Pad the year string to four digits.
//					let yearComponentSizingString = NSString(string: "00")
//					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
//				} else if (calendarComponent == .space) {
//					size = 5
//				}
////
//////				self.pickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -(size / 2)).isActive = true
//////				self.pickerView.layoutIfNeeded()
////
////
////				// Add the width buffer in order to allow the picker components not to run up against the edges
//				return CGFloat(size + widthBuffer)
////				return (U.screenWidth / 2) - 10
////
////
////		return (U.screenWidth / 2) - 20
////		return 300
////
////
//			}
}




