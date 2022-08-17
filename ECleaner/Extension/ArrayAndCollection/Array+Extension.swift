//
//  Array+Extension.swift
//  ECleaner
//
//  Created by alekseii sorochan on 30.06.2021.
//

import Foundation
import Contacts

extension Array {
    
//    @discardableResult
//    mutating func append(_ newArray: Array) -> CountableRange<Int> {
//        let range = count..<(count + newArray.count)
//        self += newArray
//        return range
//    }
    
    @discardableResult
    mutating func insert(_ newArray: Array, at index: Int) -> CountableRange<Int> {
        let mIndex = Swift.max(0, index)
        let start = Swift.min(count, mIndex)
        let end = start + newArray.count
        
        let left = self[0..<start]
        let right = self[start..<count]
        self = left + newArray + right
        return start..<end
    }
    
    mutating func remove<T: AnyObject> (_ element: T) {
        let anotherSelf = self
        
        removeAll(keepingCapacity: true)
        
        anotherSelf.each { (index: Int, current: Element) in
            if (current as! T) !== element {
                self.append(current)
            }
        }
    }
    
    func each(_ exe: (Int, Element) -> ()) {
        for (index, item) in enumerated() {
            exe(index, item)
        }
    }
}

extension Array where Element: Equatable {
    
    /// Remove Dublicates
    var unique: [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        return self.reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }

    /// Check if array contains an array of elements.
    ///
    /// - Parameter elements: array of elements to check.
    /// - Returns: true if array contains all given items.
    public func contains(_ elements: [Element]) -> Bool {
        guard !elements.isEmpty else { // elements array is empty
            return false
        }
        var found = true
        for element in elements {
            if !contains(element) {
                found = false
            }
        }
        return found
    }
    
    /// All indexes of specified item.
    ///
    /// - Parameter item: item to check.
    /// - Returns: an array with all indexes of the given item.
    public func indexes(of item: Element) -> [Int] {
        var indexes: [Int] = []
        for index in 0..<self.count {
            if self[index] == item {
                indexes.append(index)
            }
        }
        return indexes
    }
    
    /// Remove all instances of an item from array.
    ///
    /// - Parameter item: item to remove.
    public mutating func removeAll(_ item: Element) {
        self = self.filter { $0 != item }
    }
    
    /// Creates an array of elements split into groups the length of size.
    /// If array can’t be split evenly, the final chunk will be the remaining elements.
    ///
    /// - parameter array: to chunk
    /// - parameter size: size of each chunk
    /// - returns: array elements chunked
    public func chunk(size: Int = 1) -> [[Element]] {
        var result = [[Element]]()
        var chunk = -1
        for (index, elem) in self.enumerated() {
            if index % size == 0 {
                result.append([Element]())
                chunk += 1
            }
            result[chunk].append(elem)
        }
        return result
    }
}

public extension Array {
    
    /// Random item from array.
    var randomItem: Element? {
        if self.isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
    
    /// Shuffled version of array.
     var shuffled: [Element] {
        var arr = self
        for _ in 0..<10 {
            arr.sort { (_,_) in arc4random() < arc4random() }
        }
        return arr
    }
    
    /// Shuffle array.
     mutating func shuffle() {
        // https://gist.github.com/ijoshsmith/5e3c7d8c2099a3fe8dc3
        for _ in 0..<10 {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }

    /// Element at the given index if it exists.
    ///
    /// - Parameter index: index of element.
    /// - Returns: optional element (if exists).
    func item(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}

extension Array {
	
	subscript(safe index: Int) -> Element? {
		return indices ~= index ? self[index] : nil
	}
}

extension Array {
	
    mutating func remove(elementsAtIndices indicesToRemove: [Int]) -> [Element?] {
		
        guard !indicesToRemove.isEmpty else {
            return []
        }
	
        // Copy the removed elements in the specified order. UPD // alexey sorochan /// use safe for index erropr
		let removedElements = indicesToRemove.map({ self[safe: $0]})

        // Sort the indices to remove.
        let indicesToRemove = indicesToRemove.sorted()

        // Shift the elements we want to keep to the left.
        var destIndex = indicesToRemove.first!
        var srcIndex = destIndex + 1
        func shiftLeft(untilIndex index: Int) {
            while srcIndex < index {
                self[destIndex] = self[srcIndex]
                destIndex += 1
                srcIndex += 1
            }
            srcIndex += 1
        }
        for removeIndex in indicesToRemove[1...] {
            shiftLeft(untilIndex: removeIndex)
        }
        shiftLeft(untilIndex: self.endIndex)

        // Remove the extra elements from the end of the array.
        self.removeLast(indicesToRemove.count)
		
        return removedElements
    }
}

extension Collection where Element: Equatable {

	func intersection(with filter: [Element]) -> [Element] {
		return self.filter { element in filter.contains(element) }
	}

}

extension Array where Element: Equatable {
	mutating func moveElement(_ element: Element, to newIndex: Index) {
		if let oldIndex: Int = self.firstIndex(of: element) { self.move(from: oldIndex, to: newIndex) }
	}
}

extension Array {
	
	mutating func move(from oldIndex: Index, to newIndex: Index) {
		// Don't work for free and use swap when indices are next to each other - this
		// won't rebuild array and will be super efficient.
		if oldIndex == newIndex { return }
		if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
		self.insert(self.remove(at: oldIndex), at: newIndex)
	}
}

extension Array {
	
	func unique<T:Hashable>(map: ((Element) -> (T))) -> [Element] {
		var set = Set<T>()
		var arrayOrdered = [Element]()
		for value in self {
			if !set.contains(map(value)) {
				set.insert(map(value))
				arrayOrdered.append(value)
			}
		}
		return arrayOrdered
	}
}

extension MutableCollection where Self: RangeReplaceableCollection {
	private mutating func removeSopted<C>(elementsAtSortedIndices indicesToRemove: C) where C: Collection, C.Element == Index {
			// Shift the elements we want to keep to the left.
		var destIndex = indicesToRemove.first!
		precondition(indices.contains(destIndex), "Index out of range")
		var srcIndex = index(after: destIndex)
		var previousRemovalIndex = destIndex
		func shiftLeft(untilIndex index: Index) {
			precondition(index != previousRemovalIndex, "Duplicate indices")
			while srcIndex < index {
				swapAt(destIndex, srcIndex)
				formIndex(after: &destIndex)
				formIndex(after: &srcIndex)
			}
			formIndex(after: &srcIndex)
		}
		
		let secondIndex = indicesToRemove.index(after: indicesToRemove.startIndex)
		for removeIndex in indicesToRemove[secondIndex...] {
			precondition(indices.contains(removeIndex), "Index out of range")
			shiftLeft(untilIndex: removeIndex)
		}
		shiftLeft(untilIndex: endIndex)
		
			// Remove the extra elements from the end of the collection.
		removeSubrange(destIndex..<endIndex)
	}
	mutating func remove<C>(elementsAtIndices indicesToRemove: C) where C: Collection, C.Element == Index {
		guard !indicesToRemove.isEmpty else { return }
		
		// Check if the indices are sorted.
		var isSorted = true
		var prevIndex = indicesToRemove.first!
		let secondIndex = indicesToRemove.index(after: indicesToRemove.startIndex)
		for index in indicesToRemove[secondIndex...] {
			if index < prevIndex {
				isSorted = false
				break
			}
			prevIndex = index
		}
		
		if isSorted {
			removeSopted(elementsAtSortedIndices: indicesToRemove)
		} else {
			removeSopted(elementsAtSortedIndices: indicesToRemove.sorted())
		}
	}
}



