//
//  SortingType.swift
//  ECleaner
//
//  Created by alexey sorochan on 30.07.2022.
//

import Foundation

enum SortingType: CaseIterable {
	case date
	case size
	case dimension
	case edit
	case duration
	
	var descriptorKey: SortingDesriptionKey {
		switch self {
			case .date:
				return .creationDate
			case .size:
				return .fileSize
			case .dimension:
				return .pixelHeight
			case .edit:
				return .modificationDate
			case .duration:
				return .duration
		}
	}
	
	var title: String {
		switch self {
			case .date:
				return "Sort by date"
			case .size:
				return "Sort by size"
			case .dimension:
				return "Sort by Dimension"
			case .edit:
				return "Sort By Edit"
			case .duration:
				return "Sort By Duration"
		}
	}
	
	var image: UIImage {
		switch self {
			case .date:
				return UIImage()
			case .size:
				return UIImage()
			case .dimension:
				return UIImage()
			case .edit:
				return UIImage()
			case .duration:
				return UIImage()
		}
	}
}
