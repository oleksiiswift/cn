//
//  Arrray+Rearranged.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import Foundation

extension Array where Element: Equatable {
    
    mutating func move(_ item: Element, to newIndex: Index) {
        if let index = firstIndex(of: item) {
            move(at: index, to: newIndex)
        }
    }

    mutating func bringToFront(item: Element) {
        move(item, to: 0)
    }

    mutating func sendToBack(item: Element) {
        move(item, to: endIndex-1)
    }
}

extension Array {
    mutating func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
}

extension Array where Element: Equatable {
    mutating func moveToIndex(_ element: Element, to newIndex: Index) {
        if let oldIndex: Int = self.firstIndex(of: element) {
            self.moveOldToNew(from: oldIndex, to: newIndex) }
    }
}

extension Array {
    
    mutating func moveOldToNew(from oldIndex: Index, to newIndex: Index) {
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}

public extension Sequence where Element : Hashable {
	func containsElements(_ elements: [Element]) -> Bool {
		return Set(elements).isSubset(of:Set(self))
	}
}

extension Sequence where Iterator.Element : Hashable {

	func intersects<S : Sequence>(with sequence: S) -> Bool
		where S.Iterator.Element == Iterator.Element
	{
		let sequenceSet = Set(sequence)
		return self.contains(where: sequenceSet.contains)
	}
}

extension Array where Element: Equatable {
  func subtracting(_ array: [Element]) -> [Element] {
	  self.filter { !array.contains($0) }
  }

  mutating func remove(_ array: [Element]) {
	  self = self.subtracting(array)
  }
}
