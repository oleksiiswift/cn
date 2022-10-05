//
//  String+Secionds.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.03.2022.
//

import Foundation

extension String {
	
	func getSeconds() -> Int {
		let components = self.components(separatedBy: ":")
		var seconds = 0
		var multiplies = [1]
		if components.count > 1 {
			multiplies.insert(60, at:0)
			if components.count > 2 {
				multiplies.insert(60 * 60, at:0)
			}
		}
		for index in 0..<components.count {
			if let s = Int(components[index]) {
				seconds += s * multiplies[index]
			}
		}
		return seconds
	}
	
	static func fromSeconds(_ seconds: Int) -> String {
		let hours = Swift.max(0, seconds / 3600)
		let minutes = Swift.max(0, (seconds % 3600) / 60)
		let seconds = Swift.max(0, (seconds % 3600) % 60)
		var ret = String(format: "0:%02d", seconds)
		if minutes > 0 {
			ret = String(format: "%d:%02d", minutes, seconds)
			if hours > 0 {
				ret = String(format: "%d:%02d:%02d", hours, minutes, seconds)
			}
		}
		return ret
	}
}
