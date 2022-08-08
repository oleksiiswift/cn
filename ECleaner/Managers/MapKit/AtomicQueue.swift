//
//  AtomicQueue.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import Foundation

@propertyWrapper
class Atomic<Value> {
	private let queue = DispatchQueue(label: "Atomic serial queue", attributes: .concurrent)
	
	private var _value: Value
	
	init(wrappedValue value: Value) {
		self._value = value
	}
	
	var wrappedValue: Value {
		get { return queue.sync { _value } }
		set { queue.async(flags: .barrier) { self._value = newValue } }
	}
}
