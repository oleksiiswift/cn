//
//  Array+Repeated.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2022.
//

import Foundation

extension Array {
  init(repeating: [Element], count: Int) {
	self.init([[Element]](repeating: repeating, count: count).flatMap{$0})
  }

  func repeated(count: Int) -> [Element] {
	return [Element](repeating: self, count: count)
  }
}
