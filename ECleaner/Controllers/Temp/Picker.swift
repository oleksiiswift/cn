//
//  Picker.swift
//  ECleaner
//
//  Created by alexey sorochan on 08.12.2021.
//

import Foundation
import UIKit


//public class HEDatePicker: UIControl {


// MARK: - Protocols
// MARK: UIPickerViewDelegate
//extension HEDatePicker: UIPickerViewDelegate {
//
//
//	
//	
//	
//	
//	public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//
//		if #available(iOS 14.0, *) {
//			  let height: CGFloat = 0.5
//			  for subview in pickerView.subviews {
//				/* smaller than the row height plus 20 point, such as 40 + 20 = 60*/
//				if subview.frame.size.height < 60 {
//				  if subview.subviews.isEmpty {
//					let topLineView = UIView()
//					topLineView.frame = CGRect(x: 0.0, y: 0.0, width: subview.frame.size.width, height: height)
//					  topLineView.backgroundColor = .clear
//					subview.addSubview(topLineView)
//					let bottomLineView = UIView()
//					bottomLineView.frame = CGRect(x: 0.0, y: subview.frame.size.height - height, width: subview.frame.size.width, height: height)
//					bottomLineView.backgroundColor = .clear
//					subview.addSubview(bottomLineView)
//				  }
//				}
//				subview.backgroundColor = .clear
//
////				  if subview.frame.size.height < 32 {
////					  subview.frame = CGRect(x: 0.0, y: 0.0, width: U.screenWidth / 2, height: 30)
////					  subview.backgroundColor = .red
////				  }
//
//			  }
//			}
////
////
//
////		pickerView.subviews.first?.subviews.last?.backgroundColor = UIColor.red
//
////		if let sView = pickerView.subviews.last?.subviews.first {
////			sView.frame = CGRect(x: 150, y: 0, width: U.screenWidth / 2, height: 33)
//////			sView.backgroundColor = .red
////
////		}
////
//
//
//
//
//
////		let label = view as? UILabel == nil ? UILabel() : view as! UILabel
//
//		let label = UILabel()
//
//
//
//
//		label.font = self.isRowEnabled(row, forComponent: self.componentAtIndex(component)) ? .systemFont(ofSize: 20, weight: .bold) : .systemFont(ofSize: 10, weight: .medium)
////		label.backgroundColor = .red
////		label.font = self.font
////		label.textColor = self.textColor
//		if self.calendar.identifier == .persian {
////			label.text = self.titleForRow(row, inComponentIndex: component).changeNumbers()
////			label.textAlignment = .center
//		} else {
//
//
//
////			label.text = self.titleForRow(row, inComponentIndex: component)
//////			label.textAlignment = self.componentAtIndex(component) == .month ? .left : .right
////
//			if self.componentAtIndex(component) == .month {
////				if pickerView.selectedRow(inComponent: component) == row {
//////					label.rightPickerMargin(margin: 0)
////				} else {
////					label.rightPickerMargin(margin: 20)
////				}
//			} else if self.componentAtIndex(component) == .year {
////				label.leftPickerMargin(margin: 20)
//			}
////		}
////		label.textAlignment = .center
//
//			label.font = self.font
////		if pickerView.selectedRow(inComponent: component) == row {
//////			   label.backgroundColor = UIColor.green
//////			   label.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
//////			   label.layer.cornerRadius = 18
//////			   label.layer.masksToBounds = true
////			   label.textColor = .white
////			   label.text = self.titleForRow(row, inComponentIndex: component)
//////			   label.textAlignment = .center
////
////			if self.componentAtIndex(component) == .month {
//////				if pickerView.selectedRow(inComponent: component) == row {
////////					label.rightPickerMargin(margin: 0)
//////				} else {
//////					label.rightPickerMargin(margin: 10)
//////				}
////			} else if self.componentAtIndex(component) == .year {
//////				label.leftPickerMargin(margin: 10)
////			}
////
////
////
////		   } else {
////			   label.font = .systemFont(ofSize: 18, weight: .medium)
////			   label.layer.cornerRadius = 25
//
////			   label.layer.cornerRadius = 18
////			   label.layer.masksToBounds = true
//			   label.textColor = .white
//			   label.text = self.titleForRow(row, inComponentIndex: component)
////			   label.textAlignment = .center
//
//
//			   if self.componentAtIndex(component) == .month {
////				   label.rightPickerMargin(margin: 80)
//				   label.textAlignment = .right
////   				if pickerView.selectedRow(inComponent: component) != row {
////   ////					label.rightPickerMargin(margin: 0)
////										   label.rightPickerMargin(margin: 20)
////   				} else {
////					label.rightPickerMargin(margin: 10)
//////				   label.textAlignment = .right
////   				}
////
////				   label.frame = CGRect(x: -600, y: 0, width: 0, height: 36)
////					   					   label.rightPickerMargin(margin: 20)
////				   label.textAlignment = .right
////				   label.rightPickerMargin(margin: 20)
//			   } else if self.componentAtIndex(component) == .year {
////					   				   label.leftPickerMargin(margin: 80)
//				   label.textAlignment = .center
////				   label.textAlignment = .left
////				   label.textAlignment = .left
////				   label.frame = CGRect(x: pickerView.frame.width / 2, y: 0, width: pickerView.frame.width / 2, height: 36)
//
//
////				   if pickerView.selectedRow(inComponent: component) != row {
////	  ////					label.rightPickerMargin(margin: 0)
////											  label.leftPickerMargin(margin: 20)
////				   } else {
////					   label.leftPickerMargin(margin: 10)
////   //				   label.textAlignment = .right
////				   }
//
//			   }
////		   }
//
//
//
//
//		}
//
////		label.frame = CGRect(x: 0, y: 0, width: U.screenWidth / 2, height: 30)
//
////		label.sizeToFit()
////		label.textAlignment = .center
//
////		label.text = self.titleForRow(row, inComponentIndex: component)
//		label.textColor = self.isRowEnabled(row, forComponent: self.componentAtIndex(component)) ? self.textColor : self.disabledTextColor
//		return label
//
////		var pickerLabel = view as? UILabel
////
////			if (pickerLabel == nil)
////			{
////				pickerLabel = UILabel()
////
////			pickerLabel?.font = .systemFont(ofSize: 20, weight: .bold)
////			pickerLabel?.textAlignment = NSTextAlignment.right
////			}
////
//////			if component < self.pickerViewDataSource.count && row < self.pickerViewDataSource[component].count {
//////				pickerLabel?.text = self.pickerViewDataSource[component][row]
//////			}
////		if self.componentAtIndex(component) == .month {
////			pickerLabel?.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
////		}
////
////
////
////		pickerLabel?.text = self.titleForRow(row, inComponentIndex: component)
////
////
//////			pickerLabel!.adjustsFontSizeToFitWidth = true
////			return pickerLabel!
//
//	}
//	
//	
//	
////	public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//////		var pickerLabel = view as! UILabel?
////		var pickerLabel = UILabel()
////		let titleData = self.titleForRow(row, inComponentIndex: component)
////		var myString1 = NSMutableAttributedString(string:titleData)
////		let myString1Font1: UIFont = .systemFont(ofSize: 26, weight: .black)
////		let myString1Color1 = UIColor(red: 0.292745, green: 0.461693, blue: 0.998524, alpha: 1.000000)
////		let originalNSString = myString1.string as NSString
////		let myString1Range1 = originalNSString.range(of: titleData)
////		var myString1ParaStyle1 = NSMutableParagraphStyle()
////		myString1ParaStyle1.baseWritingDirection = NSWritingDirection.natural
////		myString1ParaStyle1.lineBreakMode = NSLineBreakMode.byWordWrapping
////		myString1.addAttribute(NSAttributedString.Key.underlineColor, value:myString1Color1, range:myString1Range1)
////		myString1.addAttribute(NSAttributedString.Key.paragraphStyle, value:myString1ParaStyle1, range:myString1Range1)
////		myString1.addAttribute(NSAttributedString.Key.font, value:myString1Font1, range:myString1Range1)
////		pickerLabel.attributedText = myString1
////
////		if self.componentAtIndex(component) == .month {
////							myString1ParaStyle1.alignment = NSTextAlignment.right
////		} else if self.componentAtIndex(component) == .year {
////							myString1ParaStyle1.alignment = NSTextAlignment.center
////
////		}
////
////
////		return pickerLabel
////	}
////
////	public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
////
////
////		return (pickerView.frame.width / 2.5)
//////		return .greatestFiniteMagnitude
////	}
//	
//	
////			public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
////				let widthBuffer = 25.0
////
////				let calendarComponent = self.componentAtIndex(component)
////				let stringSizingAttributes = [NSAttributedString.Key.font : self.font]
////				var size = 0.01
////
////				if calendarComponent == .month {
////					let dateFormatter = self.dateFormatter()
////
////					let yearComponentSizingString = NSString(string: "0000000000")
////					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
////					// Get the length of the longest month string and set the size to it.
//////					for symbol in dateFormatter.monthSymbols! {
//////						let monthSize = NSString(string: symbol).size(withAttributes: stringSizingAttributes)
//////
//////						size = max(size, Double(monthSize.width - 20))
////////						size = 200
//////					}
////				} else if calendarComponent == .day{
////					// Pad the day string to two digits
////					let dayComponentSizingString = NSString(string: "00")
////					size = Double(dayComponentSizingString.size(withAttributes: stringSizingAttributes).width)
////				} else if calendarComponent == .year  {
////					// Pad the year string to four digits.
////					let yearComponentSizingString = NSString(string: "00")
////					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
////				} else if calendarComponent == .hour  {
////					// Pad the year string to four digits.
////					let yearComponentSizingString = NSString(string: "00")
////					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
////				} else if calendarComponent == .minute  {
////					// Pad the year string to four digits.
////					let yearComponentSizingString = NSString(string: "00")
////					size = Double(yearComponentSizingString.size(withAttributes: stringSizingAttributes).width)
////				} else if (calendarComponent == .space) {
////					size = 5
////				}
////
//////				self.pickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -(size / 2)).isActive = true
//////				self.pickerView.layoutIfNeeded()
////
////
////				// Add the width buffer in order to allow the picker components not to run up against the edges
//////				return CGFloat(size + widthBuffer)
//////				return (U.screenWidth / 2)
////
////
////
////
////			}
//	
////	public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
////
////		return
////	}
//	
////	public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
////		let titleData = titleForRow(row, inComponentIndex: component)
////
////		var myString1 = NSMutableAttributedString(string:titleData)
////		let myString1Font1: UIFont = .systemFont(ofSize: 26, weight: .black)
////		let myString1Color1 = UIColor(red: 0.292745, green: 0.461693, blue: 0.998524, alpha: 1.000000)
////		let originalNSString = myString1.string as NSString
////		let myString1Range1 = originalNSString.range(of: titleData)
////		var myString1ParaStyle1 = NSMutableParagraphStyle()
////		myString1ParaStyle1.baseWritingDirection = NSWritingDirection.natural
////		myString1ParaStyle1.lineBreakMode = NSLineBreakMode.byWordWrapping
////		myString1.addAttribute(NSAttributedString.Key.underlineColor, value:myString1Color1, range:myString1Range1)
////		myString1.addAttribute(NSAttributedString.Key.paragraphStyle, value:myString1ParaStyle1, range:myString1Range1)
////		myString1.addAttribute(NSAttributedString.Key.font, value:myString1Font1, range:myString1Range1)
////
//////		if pickerView == myPickerf {
//////			myString1ParaStyle1.alignment = NSTextAlignment.left
//////		} else if pickerView == myPicker {
//////			myString1ParaStyle1.alignment = NSTextAlignment.right
//////		}
////
////		if self.componentAtIndex(component) == .month {
////							myString1ParaStyle1.alignment = NSTextAlignment.right
////		} else if self.componentAtIndex(component) == .year {
////							myString1ParaStyle1.alignment = NSTextAlignment.center
////		}
////
////		return myString1
////	}
//	
//	
//	
//}
