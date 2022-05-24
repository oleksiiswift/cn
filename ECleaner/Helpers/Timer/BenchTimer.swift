//
//  BenchTimer..swift
//  ECleaner
//
//  Created by alexey sorochan on 23.04.2022.
//

import CoreFoundation

class BenchTimer {
	
	let startTime: CFAbsoluteTime
	var endTime: CFAbsoluteTime?

	init() {
		startTime = CFAbsoluteTimeGetCurrent()
	}

	func stop() -> CFAbsoluteTime {
		endTime = CFAbsoluteTimeGetCurrent()

		return duration!
	}

	var duration: CFAbsoluteTime? {
		if let endTime = endTime {
			return endTime - startTime
		} else {
			return nil
		}
	}
}
