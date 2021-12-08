//
//  Picker.swift
//  ECleaner
//
//  Created by alexey sorochan on 08.12.2021.
//

import Foundation
import UIKit

public enum HEDatePickerType: String {
	
	case year = "y",
		 yearMonth = "My",
		 date = "yMd",
		 dateTime = "yMdWhm",
		 custom = ""
}

public extension Date {

	func hour() -> Int {
		let hour = Calendar.current.component(.hour, from: self)
		return hour
	}
	func minute() -> Int {
		let minute = Calendar.current.component(.minute, from: self)
		return minute
	}

	func day() -> Int {
		let day = Calendar.current.component(.day, from: self)
		return day
	}
	func month() -> Int {
		let month = Calendar.current.component(.month, from: self)
		return month
	}
	func year() -> Int {
		let year = Calendar.current.component(.year, from: self)
		return year
	}
	
	func jalaali() -> JalaaliDate {
		return toJalaali(gy: year(), month(), day())
	}
}


public extension String {
	func changeNumbers() -> String {
		
		var str = self
		let numbersDictionary = ["1": "۱",
								 "2": "۲",
								 "3": "۳",
								 "4": "۴",
								 "5": "۵",
								 "6": "۶",
								 "7": "۷",
								 "8": "۸",
								 "9": "۹",
								 "0": "۰"]
		
		for key in numbersDictionary.keys {
			str = str.replacingOccurrences(of: key, with: numbersDictionary[key]!)
		}
		
		return str
	}
}

public protocol HEDatePickerDelegate {
	func pickerView(_ pickerView: HEDatePicker, didSelectRow row: Int, inComponent component: Int)
}

enum HEDatePickerComponents : Character  {
	case invalid   = "!",
			year   = "y",
			month  = "M",
			day    = "d",
			hour   = "h",
			minute = "m",
			space  = "W"
}

public class HEDatePicker: UIControl {
	
	// MARK: - Public Properties
	public var delegate: HEDatePickerDelegate?
	/// The font for the date picker.
	public var font: UIFont = .systemFont(ofSize: 28, weight: .bold)
	/// The text color for the date picker components.
	public var textColor = UIColor.black
	/// The minimum date to show for the date picker. Set to NSDate.distantPast() by default
	public var minimumDate = Date.distantPast {
		didSet {
			self.validateMinimumAndMaximumDate()
		}
	}
	/// The maximum date to show for the date picker. Set to NSDate.distantFuture() by default
	public var maximumDate = Date.distantFuture {
		didSet {
			self.validateMinimumAndMaximumDate()
		}
	}
	/// The current locale to use for formatting the date picker. By default, set to the device's current locale
	public var locale : Locale = Locale.current {
		didSet {
			self.calendar.locale = self.locale
		}
	}
	public var identifier: Calendar.Identifier = .gregorian {
		didSet {
			self.calendar = Calendar(identifier: identifier)
			self.updatePickerViewComponentValuesAnimated(false)
		}
	}
	/// The current date value of the date picker.
	public fileprivate(set) var date = Date()

	public var pickerType: HEDatePickerType = .dateTime
	public var customPickerType = ""
	
	// MARK: - Private Variables
	fileprivate let numberofYears = 200
	/// The internal picker view used for laying out the date components.
	fileprivate let pickerView = UIPickerView()
	/// The calendar used for formatting dates.
	fileprivate var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
	/// Calculates the current calendar components for the current date.
	fileprivate var currentCalendarComponents : DateComponents {
		get {
			return (self.calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: self.date)
		}
	}
	/// Gets the text color to be used for the label in a disabled state
	fileprivate var disabledTextColor : UIColor {
		get {
			var r : CGFloat = 0
			var g : CGFloat = 0
			var b : CGFloat = 0
			
			self.textColor.getRed(&r, green: &g, blue: &b, alpha: nil)
			
			return UIColor(red: r, green: g, blue: b, alpha: 0.35)
		}
	}
	/// The order in which each component should be ordered in.
	fileprivate var datePickerComponentOrdering = [HEDatePickerComponents]()
	
	// MARK: - LifeCycle
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}
	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}
	
	/**
	Handles the common initialization amongst all init()
	*/
	func commonInit() {
		self.pickerView.dataSource = self
		self.pickerView.delegate = self
		
		self.addSubview(self.pickerView)
		pickerView.translatesAutoresizingMaskIntoConstraints = false
//		let topConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
//		let bottomConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
//		let leftConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
//		let rightConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
		
		self.pickerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
		self.pickerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
		self.pickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
		self.pickerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
		self.pickerView.layoutIfNeeded()
		
		let middleLineView = UIView()
		
		self.addSubview(middleLineView)
		middleLineView.translatesAutoresizingMaskIntoConstraints = false
		middleLineView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		middleLineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
		middleLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		middleLineView.widthAnchor.constraint(equalToConstant: 3).isActive = true
		
		middleLineView.backgroundColor = .red
		

//		pickerView.setValue(UIColor.red, forKey: "_magnifierLineColor")
		
	
		
//		self.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
	}
	
	// MARK: - Override
	public override var intrinsicContentSize : CGSize {
		return self.pickerView.intrinsicContentSize
	}
	
	public override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		self.reloadAllComponents()
		
		self.setDate(self.date)
	}
	
	// MARK: - Public
	
	/**
	 Reloads all of the components in the date picker.
	 */
	public func reloadAllComponents() {
		self.datePickerComponentOrdering = [HEDatePickerComponents]()
		self.refreshComponentOrdering()
		self.pickerView.reloadAllComponents()
	}
	
	/**
	 Sets the current date value for the date picker.
	 
	 :param: date     The date to set the picker to.
	 :param: animated True if the date picker should changed with an animation; otherwise false,
	 */
	public func setDate(_ date : Date, animated : Bool) {
		self.date = date
		self.updatePickerViewComponentValuesAnimated(animated)
	}
	
	// MARK: - Private
	
	/**
	 Sets the current date with no animation.
	 
	 :param: date The date to be set.
	 */
	fileprivate func setDate(_ date : Date) {
		self.setDate(date, animated: false)
	}
	
	/**
	 Creates a new date formatter with the locale and calendar
	 
	 :returns: A new instance of NSDateFormatter
	 */
	fileprivate func dateFormatter() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = self.calendar
		dateFormatter.locale = self.locale
		
		return dateFormatter
	}
	
	/**
	 Refreshes the ordering of components based on the current locale. Calling this function will not refresh the picker view.
	 */
	fileprivate func refreshComponentOrdering() {

		var format = self.pickerType.rawValue
		if self.pickerType == .custom {
			format = self.customPickerType
		}
		
		format.forEach { (component) in
			if let pickerComponent = HEDatePickerComponents(rawValue: component) {
				self.datePickerComponentOrdering.append(pickerComponent)
			}
		}
	}
	
	/**
	 Validates that the set minimum and maximum dates are valid.
	 */
	fileprivate func validateMinimumAndMaximumDate() {
		let ordering = self.minimumDate.compare(self.maximumDate)
		if (ordering != .orderedAscending ){
			fatalError("Cannot set a maximum date that is equal or less than the minimum date.")
		}
	}
	
	/**
	 Gets the value of the current component at the specified row.
	 
	 :param: row            The row index whose value is required
	 :param: componentIndex The component index for the row.
	 
	 :returns: A string containing the value of the current row at the component index.
	 */
	fileprivate func titleForRow(_ row : Int, inComponentIndex componentIndex: Int) -> String {
		let dateComponent = self.componentAtIndex(componentIndex)
		
		let value = self.rawValueForRow(row, inComponent: dateComponent)
	  
		if dateComponent == HEDatePickerComponents.month {
			let dateFormatter = self.dateFormatter()
			return dateFormatter.monthSymbols[value - 1]
		} else if dateComponent == .hour || dateComponent == .minute {
			return String(format: "%02d", value)
		} else {
			return String(value)
		}
	}
	
	/**
	 Gets the value of the input component using the current date.
	 
	 :param: component The component whose value is needed.
	 
	 :returns: The value of the component.
	 */
	fileprivate func valueForDateComponent(_ component : HEDatePickerComponents) -> Int{
		if component == .year {
			return self.currentCalendarComponents.year!
		} else if component == .day {
			return self.currentCalendarComponents.day!
		} else if component == .month {
			return self.currentCalendarComponents.month!
		} else if component == .hour {
			return self.currentCalendarComponents.hour!
		} else if component == .minute {
			return self.currentCalendarComponents.minute!
		}
		
		return -1
	}
	
	/**
	 Gets the maximum range for the specified date picker component.
	 
	 :param: component The component to get the range for.
	 
	 :returns: The maximum date range for that component.
	 */
	fileprivate func maximumRangeForComponent(_ component : HEDatePickerComponents) -> Range<Int> {
		var calendarUnit : Calendar.Component
		if component == .year {
			var currentYear = Date().year()
			if self.calendar.identifier == .persian {
				currentYear = Date().jalaali().year
			}
		  
			return Range(uncheckedBounds: (lower: currentYear - numberofYears / 2, upper: currentYear + numberofYears / 2))
			
		} else if component == .day {
			calendarUnit = .day
		} else if component == .month {
			calendarUnit = .month
		} else if component == .hour {
			calendarUnit = .hour
		} else if component == .minute {
			calendarUnit = .minute
		} else {
			return Range(uncheckedBounds: (lower: 0, upper: 0))
		}
		
		
		return self.calendar.maximumRange(of: calendarUnit)!
	}
	
	/**
	 Calculates the raw value of the row at the current index.
	 
	 :param: row       The row to get.
	 :param: component The component which the row belongs to.
	 
	 :returns: The raw value of the row, in integer. Use NSDateComponents to convert to a usable date object.
	 */
	fileprivate func rawValueForRow(_ row : Int, inComponent component : HEDatePickerComponents) -> Int {
		if component == .space {
			return -1
		}
		
		let calendarUnitRange = self.maximumRangeForComponent(component)
		return calendarUnitRange.lowerBound + (row % (calendarUnitRange.upperBound - calendarUnitRange.lowerBound))
	}
	
	/**
	 Checks if the specified row should be enabled or not.
	 
	 :param: row       The row to check.
	 :param: component The component to check the row in.
	 
	 :returns: YES if the row should be enabled; otherwise NO.
	 */
	fileprivate func isRowEnabled(_ row: Int, forComponent component : HEDatePickerComponents) -> Bool {
		
		let rawValue = self.rawValueForRow(row, inComponent: component)
		
		var components = DateComponents()
		components.year = self.currentCalendarComponents.year
		components.month = self.currentCalendarComponents.month
		components.day = self.currentCalendarComponents.day
		components.hour = self.currentCalendarComponents.hour
		components.minute = self.currentCalendarComponents.minute
		
		if component == .year {
			components.year = rawValue
		} else if component == .day {
			components.day = rawValue
		} else if component == .month {
			components.month = rawValue
		} else if component == .hour {
			components.hour = rawValue
		} else if component == .minute {
			components.minute = rawValue
		}
		
		let dateForRow = self.calendar.date(from: components)!
		
		return self.dateIsInRange(dateForRow)
	}
	
	/**
	 Checks if the input date falls within the date picker's minimum and maximum date ranges.
	 
	 :param: date The date to be checked.
	 
	 :returns: True if the input date is within range of the minimum and maximum; otherwise false.
	 */
	fileprivate func dateIsInRange(_ date : Date) -> Bool {
		return self.minimumDate.compare(date) != ComparisonResult.orderedDescending &&
			self.maximumDate.compare(date) != ComparisonResult.orderedAscending
	}
	
	/**
	 Updates all of the date picker components to the value of the current date.
	 
	 :param: animated True if the update should be animated; otherwise false.
	 */
	fileprivate func updatePickerViewComponentValuesAnimated(_ animated : Bool) {
		for (_, dateComponent) in self.datePickerComponentOrdering.enumerated() {
			self.setIndexOfComponent(dateComponent, animated: animated)
		}
	}
	
	/**
	 Updates the index of the specified component to its relevant value in the current date.
	 
	 :param: component The component to be updated.
	 :param: animated  True if the update should be animated; otherwise false.
	 */
	fileprivate func setIndexOfComponent(_ component : HEDatePickerComponents, animated: Bool) {
		self.setIndexOfComponent(component, toValue: self.valueForDateComponent(component), animated: animated)
	}
	
	/**
	 Updates the index of the specified component to the input value.
	 
	 :param: component The component to be updated.
	 :param: value     The value the component should be updated ot.
	 :param: animated  True if the update should be animated; otherwise false.
	 */
	fileprivate func setIndexOfComponent(_ component : HEDatePickerComponents, toValue value : Int, animated: Bool) {
		
		if component == .space {
			return
		}
		
		let componentRange = self.maximumRangeForComponent(component)
		
		let idx = (value - componentRange.lowerBound)
		let middleIndex = /*(self.maximumNumberOfRows / 2) - (maximumNumberOfRows / 2) % (componentRange.upperBound - componentRange.lowerBound) +*/ idx
		
		var componentIndex = 0
		
		for (index, dateComponent) in self.datePickerComponentOrdering.enumerated() {
			if (dateComponent == component) {
				componentIndex = index
			}
		}
		
		self.pickerView.selectRow(middleIndex, inComponent: componentIndex, animated: animated)
	}
	
	/**
	 Gets the component type at the current component index.
	 
	 :param: index The component index
	 
	 :returns: The date picker component type at the index.
	 */
	fileprivate func componentAtIndex(_ index: Int) -> HEDatePickerComponents {
		if self.datePickerComponentOrdering.count > index {
			return self.datePickerComponentOrdering[index]
		} else {
			return HEDatePickerComponents.invalid
		}
	}
	
	/**
	 Gets the number of days of the specified month in the specified year.
	 
	 :param: month The month whose maximum date value is requested.
	 :param: year  The year for which the maximum date value is required.
	 
	 :returns: The number of days in the month.
	 */
	fileprivate func numberOfDaysForMonth(_ month : Int, inYear year : Int) -> Int {
		var components = DateComponents()
		components.month = month
		components.day = 1
		components.year = year
		
		let calendarRange = (self.calendar as NSCalendar).range(of: .day, in: .month, for: self.calendar.date(from: components)!)
		let numberOfDaysInMonth = calendarRange.length
		
		return numberOfDaysInMonth
	}
	
	/**
	 Determines if updating the specified component to the input value would evaluate to a valid date using the current date values.
	 
	 :param: value     The value to be updated to.
	 :param: component The component whose value should be updated.
	 
	 :returns: True if updating the component to the specified value would result in a valid date; otherwise false.
	 */
	fileprivate func isValidValue(_ value : Int, forComponent component: HEDatePickerComponents) -> Bool {
		if (component == .year) {
			let numberOfDaysInMonth = self.numberOfDaysForMonth(self.currentCalendarComponents.month!, inYear: value)
			return self.currentCalendarComponents.day! <= numberOfDaysInMonth
		} else if (component == .day) {
			let numberOfDaysInMonth = self.numberOfDaysForMonth(self.currentCalendarComponents.month!, inYear: self.currentCalendarComponents.year!)
			return value <= numberOfDaysInMonth
		} else if (component == .month) {
			let numberOfDaysInMonth = self.numberOfDaysForMonth(value, inYear: self.currentCalendarComponents.year!)
			return self.currentCalendarComponents.day! <= numberOfDaysInMonth
		}
		
		return true
	}
	
	/**
	 Creates date components by updating the specified component to the input value. This does not do any date validation.
	 
	 :param: component The component to be updated.
	 :param: value     The value the component should be updated to.
	 
	 :returns: The components by updating the current date's components to the specified value.
	 */
	fileprivate func currentCalendarComponentsByUpdatingComponent(_ component : HEDatePickerComponents, toValue value : Int) -> DateComponents {
		var components = self.currentCalendarComponents
		
		if (component == .month) {
			components.month = value
		} else if (component == .day) {
			components.day = value
		} else if (component == .year) {
			components.year = value
		} else if (component == .hour) {
			components.hour = value
		} else if (component == .minute) {
			components.minute = value
		}
		
		return components
	}
	
	/**
	 Creates date components by updating the specified component to the input value. If the resulting value is not a valid date object, the components will be updated to the closest best value.
	 
	 :param: component The component to be updated.
	 :param: value     The value the component should be updated to.
	 
	 :returns: The components by updating the specified value; the components will be a valid date object.
	 */
	fileprivate func validDateValueByUpdatingComponent(_ component : HEDatePickerComponents, toValue value : Int) -> DateComponents {
		var components = self.currentCalendarComponentsByUpdatingComponent(component, toValue: value)
		if (!self.isValidValue(value, forComponent: component)) {
			if (component == .month) {
				components.day = self.numberOfDaysForMonth(value, inYear: components.year!)
			} else if (component == .day) {
				components.day = self.numberOfDaysForMonth(components.month!, inYear:components.year!)
			} else {
				components.day = self.numberOfDaysForMonth(components.month!, inYear: value)
			}
		}
		
		return components
	}
}

// MARK: - Protocols
// MARK: UIPickerViewDelegate
extension HEDatePicker: UIPickerViewDelegate {
	public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 30
//		return font.lineHeight + 10
	}

	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let datePickerComponent = self.componentAtIndex(component)
		let value = self.rawValueForRow(row, inComponent: datePickerComponent)
		
		// Create the newest valid date components.
		let components = self.validDateValueByUpdatingComponent(datePickerComponent, toValue: value)
		
		// If the resulting components are not in the date range ...
		if (!self.dateIsInRange(self.calendar.date(from: components)!)) {
			// ... go back to original date
			self.setDate(self.date, animated: true)
		} else {
			// Get the components that would result by just force-updating the current components.
			let rawComponents = self.currentCalendarComponentsByUpdatingComponent(datePickerComponent, toValue: value)
			
			let day = components.day!
			
			if (rawComponents.day != components.day) {
				// Only animate the change if the day value is not a valid date.
				self.setIndexOfComponent(.day, toValue: day, animated: self.isValidValue(day, forComponent: .day))
			}
			
			if (rawComponents.month != components.month) {
				self.setIndexOfComponent(.month, toValue: day, animated: datePickerComponent != .month)
			}
			
			if (rawComponents.year != components.year) {
				self.setIndexOfComponent(.year, toValue: day, animated: datePickerComponent != .year)
			}
			
			self.date = self.calendar.date(from: components)!
			self.sendActions(for: .valueChanged)
		}
		
		pickerView.reloadAllComponents()
		self.delegate?.pickerView(self, didSelectRow: row, inComponent: component)
	}
	
	
	
	public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		
//		if #available(iOS 14.0, *) {
//			  let height: CGFloat = 0.5
//			  for subview in pickerView.subviews {
//				/* smaller than the row height plus 20 point, such as 40 + 20 = 60*/
//				if subview.frame.size.height < 60 {
//				  if subview.subviews.isEmpty {
//					let topLineView = UIView()
//					topLineView.frame = CGRect(x: 0.0, y: 0.0, width: subview.frame.size.width, height: height)
//					topLineView.backgroundColor = .clear
//					subview.addSubview(topLineView)
//					let bottomLineView = UIView()
//					bottomLineView.frame = CGRect(x: 0.0, y: subview.frame.size.height - height, width: subview.frame.size.width, height: height)
//					bottomLineView.backgroundColor = .clear
//					subview.addSubview(bottomLineView)
//				  }
//				}
//				subview.backgroundColor = .clear
//			  }
//			}
//
//

//		pickerView.subviews.first?.subviews.last?.backgroundColor = UIColor.red
		
		
		
		
		
		
		
		
		let label = view as? UILabel == nil ? UILabel() : view as! UILabel
		
		

		
		
		label.font = self.isRowEnabled(row, forComponent: self.componentAtIndex(component)) ? .systemFont(ofSize: 20, weight: .bold) : .systemFont(ofSize: 10, weight: .medium)
//		label.backgroundColor = .red
//		label.font = self.font
//		label.textColor = self.textColor
		if self.calendar.identifier == .persian {
//			label.text = self.titleForRow(row, inComponentIndex: component).changeNumbers()
//			label.textAlignment = .center
		} else {
			
			
			
//			label.text = self.titleForRow(row, inComponentIndex: component)
////			label.textAlignment = self.componentAtIndex(component) == .month ? .left : .right
//
			if self.componentAtIndex(component) == .month {
//				if pickerView.selectedRow(inComponent: component) == row {
////					label.rightPickerMargin(margin: 0)
//				} else {
//					label.rightPickerMargin(margin: 20)
//				}
			} else if self.componentAtIndex(component) == .year {
//				label.leftPickerMargin(margin: 20)
			}
//		}
//		label.textAlignment = .center
		
			label.font = self.font
//		if pickerView.selectedRow(inComponent: component) == row {
////			   label.backgroundColor = UIColor.green
////			   label.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
////			   label.layer.cornerRadius = 18
////			   label.layer.masksToBounds = true
//			   label.textColor = .white
//			   label.text = self.titleForRow(row, inComponentIndex: component)
////			   label.textAlignment = .center
//
//			if self.componentAtIndex(component) == .month {
////				if pickerView.selectedRow(inComponent: component) == row {
//////					label.rightPickerMargin(margin: 0)
////				} else {
////					label.rightPickerMargin(margin: 10)
////				}
//			} else if self.componentAtIndex(component) == .year {
////				label.leftPickerMargin(margin: 10)
//			}
//
//
//
//		   } else {
//			   label.font = .systemFont(ofSize: 18, weight: .medium)
//			   label.layer.cornerRadius = 25
			
//			   label.layer.cornerRadius = 18
//			   label.layer.masksToBounds = true
			   label.textColor = .white
			   label.text = self.titleForRow(row, inComponentIndex: component)
//			   label.textAlignment = .center
			   
			   
			   if self.componentAtIndex(component) == .month {
   //				if pickerView.selectedRow(inComponent: component) == row {
   ////					label.rightPickerMargin(margin: 0)
   //				} else {
				   
//				   label.textAlignment = .right
   //				}
				   
//				   label.frame = CGRect(x: -600, y: 0, width: 0, height: 36)
//					   					   label.rightPickerMargin(margin: 20)
//				   label.textAlignment = .right
				   label.rightPickerMargin(margin: 20)
			   } else if self.componentAtIndex(component) == .year {
					   				   label.leftPickerMargin(margin: 20)
//				   label.textAlignment = .left
//				   label.textAlignment = .left
//				   label.frame = CGRect(x: pickerView.frame.width / 2, y: 0, width: pickerView.frame.width / 2, height: 36)
				   
				   
			   }
//		   }

		
		}
		
		
//		label.sizeToFit()
//		label.textAlignment = .center
		
//		label.text = self.titleForRow(row, inComponentIndex: component)
		label.textColor = self.isRowEnabled(row, forComponent: self.componentAtIndex(component)) ? self.textColor : self.disabledTextColor
		return label
		
//		var pickerLabel = view as? UILabel
//
//			if (pickerLabel == nil)
//			{
//				pickerLabel = UILabel()
//
//			pickerLabel?.font = .systemFont(ofSize: 20, weight: .bold)
//			pickerLabel?.textAlignment = NSTextAlignment.right
//			}
//
////			if component < self.pickerViewDataSource.count && row < self.pickerViewDataSource[component].count {
////				pickerLabel?.text = self.pickerViewDataSource[component][row]
////			}
//		if self.componentAtIndex(component) == .month {
//			pickerLabel?.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
//		}
//
//
//
//		pickerLabel?.text = self.titleForRow(row, inComponentIndex: component)
//
//
////			pickerLabel!.adjustsFontSizeToFitWidth = true
//			return pickerLabel!

	}
	

	
			public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
				let widthBuffer = 25.0 + 20
		
				let calendarComponent = self.componentAtIndex(component)
				let stringSizingAttributes = [NSAttributedString.Key.font : self.font]
				var size = 0.01
		
				if calendarComponent == .month {
					let dateFormatter = self.dateFormatter()
		
					// Get the length of the longest month string and set the size to it.
					for symbol in dateFormatter.monthSymbols! {
						let monthSize = NSString(string: symbol).size(withAttributes: stringSizingAttributes)
						size = max(size, Double(monthSize.width))
//						size = 200
					}
				} else if calendarComponent == .day{
					// Pad the day string to two digits
					let dayComponentSizingString = NSString(string: "00")
					size = Double(dayComponentSizingString.size(withAttributes: stringSizingAttributes).width)
				} else if calendarComponent == .year  {
					// Pad the year string to four digits.
					let yearComponentSizingString = NSString(string: "00")
					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
				} else if calendarComponent == .hour  {
					// Pad the year string to four digits.
					let yearComponentSizingString = NSString(string: "00")
					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
				} else if calendarComponent == .minute  {
					// Pad the year string to four digits.
					let yearComponentSizingString = NSString(string: "00")
					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
				} else if (calendarComponent == .space) {
					size = 20
				}
		
				// Add the width buffer in order to allow the picker components not to run up against the edges
				return CGFloat(size + widthBuffer)
//				return 150.0

				
			}
	
}




// MARK: UIPickerViewDataSource
extension HEDatePicker: UIPickerViewDataSource {
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch self.componentAtIndex(component) {
		case .month:
			return 12
		case .day:
			return 31
		case .year:
			return 200
		case .hour:
			return 24
		case .minute:
			return 60
		default:
			return 0
		}
	}
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		if self.pickerType == .custom {
			return self.customPickerType.count
		} else {
			return self.pickerType.rawValue.count
		}
	}
}


public typealias JalaaliYear = Int

/// An Int representing a Jalaali month (1-based).
public typealias JalaaliMonth = Int

/// An Int representing a Jalaali day.
public typealias JalaaliDay = Int

/// An Int representing a Gregorian year.
public typealias GregorianYear = Int

/// An Int representing a Gregorian month (1-based).
public typealias GregorianMonth = Int

/// An Int representing a Gregorian day.
public typealias GregorianDay = Int

/// An Int representing a Julian Day Number
public typealias JulianDayNumber = Int

/// A tuple for a Jalaali date.
public typealias JalaaliDate = (year: JalaaliYear, month: JalaaliMonth, day: JalaaliDay)

/// A tuple for a Gregorian date.
public typealias GregorianDate = (year: GregorianYear, month: GregorianMonth, day: GregorianDay)

// Jalaali years starting the 33-year rule.
let breaks =  [ -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210
	, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178
]

/// This function determines if the Jalaali (Persian) year is
/// leap (366-day long) or is the common year (365 days), and
/// finds the day in March (Gregorian calendar) of the first
/// day of the Jalaali year (jy).
///
/// @param jy Jalaali calendar year (-61 to 3177)
/// @return
///   leap: number of years since the last leap year (0 to 4)
///   gy: Gregorian year of the beginning of Jalaali year
///   march: the March day of Farvardin the 1st (1st day of jy)
/// @see: http://www.astro.uni.torun.pl/~kb/Papers/EMP/PersianC-EMP.htm
/// @see: http://www.fourmilab.ch/documents/calendar/
func jalCal(jy: JalaaliYear) -> (leapOffset: Int, year: GregorianYear, dayInMarch: Int) {
	assert(jy >= breaks.first!, "invalid jalaali year \(jy), should be >= \(String(describing: breaks.first))")
	assert(jy < breaks.last!, "invalid jalaali year \(jy), should be < \(String(describing: breaks.last))")
	
	let gy = jy + 621
	var leapJ = -14
	let jump = 0
	
	// Find the limiting years for the Jalaali year jy.
	var jp = breaks[0]
	for i in 1 ..< breaks.count {
		let jm = breaks[i]
		let jump = jm - jp
		if jy < jm {
			break
		}
		leapJ += jump / 33 * 8 + jump % 33 / 4
		jp = jm
	}
	var n = jy - jp
	
	// Find the number of leap years from AD 621 to the beginning
	// of the current Jalaali year in the Persian calendar.
	leapJ += n / 33 * 8 + (n % 33 + 3) / 4
	if jump % 33 == 4 && jump - n == 4 {
		leapJ += 1
	}
	
	// And the same in the Gregorian calendar (until the year gy).
	let leapG = gy / 4 - ((gy / 100) + 1) * 3 / 4 - 150
	
	// Determine the Gregorian date of Farvardin the 1st.
	let march = 20 + leapJ - leapG
	
	// Find how many years have passed since the last leap year.
	if jump - n < 6 {
		n = n - jump + (jump + 4) / 33 * 33
	}
	var leap = ((n + 1) % 33 - 1) % 4
	if leap == -1 {
		leap = 4
	}
	
	return (leap, gy, march)
}

/// Converts a date of the Jalaali calendar to the Julian Day number.
///
/// @param jy Jalaali year (1 to 3100)
/// @param jm Jalaali month (1 to 12)
/// @param jd Jalaali day (1 to 29/31)
/// @return Julian Day number
func j2d(jy: JalaaliYear, _ jm: JalaaliMonth, _ jd: JalaaliDay) -> JulianDayNumber {
	let r = jalCal(jy: jy)
	let t = g2d(gy: r.year, 3, r.dayInMarch) + (jm - 1) * 31
	return t - jm / 7 * (jm - 7) + jd - 1
}

/// Converts the Julian Day number to a date in the Jalaali calendar.
///
/// @param jdn Julian Day number
/// @return
///   jy: Jalaali year (1 to 3100)
///   jm: Jalaali month (1 to 12)
///   jd: Jalaali day (1 to 29/31)
func d2j(jdn: JulianDayNumber) -> JalaaliDate {
	let gy = d2g(jdn: jdn).year // Calculate Gregorian year (gy).
	var jy = gy - 621
	let r = jalCal(jy: jy)
	let jdn1f = g2d(gy: gy, 3, r.dayInMarch)
	var jd, jm, k: Int
	
	// Find number of days that passed since 1 Farvardin.
	k = jdn - jdn1f
	if k >= 0 {
		if k <= 185 {
			// The first 6 months.
			jm = 1 + k / 31
			jd = k % 31 + 1
			return (jy, jm, jd)
		} else {
			// The remaining months.
			k -= 186
		}
	} else {
		// Previous Jalaali year.
		jy -= 1
		k += 179
		if r.leapOffset == 1 {
			k += 1
		}
	}
	jm = 7 + k / 30
	jd = k % 30 + 1
	return (jy, jm, jd)
}

/// Calculates the Julian Day number from Gregorian or Julian
/// calendar dates. This integer number corresponds to the noon of
/// the date (i.e. 12 hours of Universal Time).
/// The procedure was tested to be good since 1 March, -100100 (of both
/// calendars) up to a few million years into the future.
///
/// @param gy Calendar year (years BC numbered 0, -1, -2, ...)
/// @param gm Calendar month (1 to 12)
/// @param gd Calendar day of the month (1 to 28/29/30/31)
/// @return Julian Day number
func g2d(gy: GregorianYear, _ gm: GregorianMonth, _ gd: GregorianDay) -> JulianDayNumber {
	var d = (gy + (gm - 8) / 6 + 100100) * 1461 / 4
		+ (153 * ((gm + 9) % 12) + 2) / 5
		+ gd - 34840408
	d = d - (gy + 100100 + (gm - 8) / 6) / 100 * 3 / 4 + 752
	return d
}

/// Calculates Gregorian and Julian calendar dates from the Julian Day number
/// (jdn) for the period since jdn=-34839655 (i.e. the year -100100 of both
/// calendars) to some millions years ahead of the present.
///
/// @param jdn Julian Day number
/// @return
///   gy: Calendar year (years BC numbered 0, -1, -2, ...)
///   gm: Calendar month (1 to 12)
///   gd: Calendar day of the month M (1 to 28/29/30/31)
func d2g(jdn: JulianDayNumber) -> GregorianDate {
	var j = 4 * jdn + 139361631
	j += (4 * jdn + 183187720) / 146097 * 3 / 4 * 4 - 3908
	let i = j % 1461 / 4 * 5 + 308
	let gd = i % 153 / 5 + 1
	let gm = i / 153 % 12 + 1
	let gy = j / 1461 - 100100 + (8 - gm) / 6
	return (gy, gm, gd)
}

/// Converts a Gregorian date to Jalaali.
public func toJalaali(gy: GregorianYear, _ gm: GregorianMonth, _ gd: GregorianDay) -> JalaaliDate {
	return d2j(jdn: g2d(gy: gy, gm, gd))
}

/// Converts a Jalaali date to Gregorian.
public func toGregorian(jy: JalaaliYear, _ jm: JalaaliMonth, _ jd: JalaaliDay) -> GregorianDate {
	return d2g(jdn: j2d(jy: jy, jm, jd))
}

/// Checks whether a Jalaali date is valid or not.
public func isValidJalaaliDate(jy: JalaaliYear, _ jm: JalaaliMonth, _ jd: JalaaliDay) -> Bool {
	return  jy >= breaks.first! && jy < breaks.last! &&
		jm >= 1 && jm <= 12 &&
		jd >= 1 && jd <= lastDayOfJalaaliMonth(jy: jy, jm)
}

/// Is this a leap year or not?
public func isLeapJalaaliYear(jy: JalaaliYear) -> Bool {
	return jalCal(jy: jy).leapOffset == 0
}

/// Number of days in a given month in a Jalaali year.
public func lastDayOfJalaaliMonth(jy: JalaaliYear, _ jm: JalaaliMonth) -> JalaaliDay {
	if jm <= 6 { return 31 }
	if jm <= 11 { return 30 }
	if isLeapJalaaliYear(jy: jy) { return 30 }
	return 29
}


//
//class MonthPickerView : UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
//
//	var months: [String]!
//	var years: [Int]!
//	var DEFAULT_SIZE = 204
//
//	var month = Calendar.current.component(.month, from: Date()) {
//		didSet {
//			selectRow(month - 1, inComponent: 0, animated: true)
//		}
//	}
//
//	var year = Calendar.current.component(.year, from: Date()) {
//		didSet {
//			selectRow(years.firstIndex(of: year)!, inComponent: 1, animated: true)
//		}
//	}
//
//	func onDateSelected() -> String {
//		return "\(month)-\(year)"
//	}
//
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		self.setup()
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//		self.setup()
//	}
//
//	func setup() {
//		let currentYear = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
//		let currentMonth = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.month, from: NSDate() as Date)
//		// population years
//		var years: [Int] = []
//		if years.count == 0 {
//			for i in (currentYear - DEFAULT_SIZE)...(currentYear + DEFAULT_SIZE) {
//				years.append(i)
//			}
//		}
//		self.years = years
//
//		// population months with localized names
//		var months: [String] = []
//		var month = 0
//		for _ in 1...12 {
//			months.append(DateFormatter().monthSymbols[month].capitalized)
//			month += 1
//		}
//		self.months = months
//
//		self.delegate = self
//		self.dataSource = self
//
//		// TODO check currentMonth relative to infinite size
//		self.selectRow((DEFAULT_SIZE / 2) - 7 + currentMonth, inComponent: 0, animated: true)
//		self.selectRow(DEFAULT_SIZE, inComponent: 1, animated: true)
//	}
//
//	// number of columns
//	func numberOfComponents(in pickerView: UIPickerView) -> Int {
//		return 2
//	}
//
//	// number of rows
//	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//		switch component {
//			case 0:
//				return DEFAULT_SIZE
//			case 1:
//				return years.count
//			default:
//				return 0
//		}
//	}
//
//	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//		switch component {
//			case 0:
//				return months[row % months.count]
//			case 1:
//				return "\(years[row])"
//			default:
//				return nil
//		}
//	}
//
//	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//		let month = self.selectedRow(inComponent: 0)+1
//		let year = years[self.selectedRow(inComponent: 1)]
//		self.month = month
//		self.year = year
//	}
//
//}
