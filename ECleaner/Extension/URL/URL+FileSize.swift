//
//  URL+FileSize.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.04.2022.
//

import Foundation

extension URL {

	func sizePerMB() -> Double {
		guard isFileURL else { return 0 }
		do {
			let attribute = try FileManager.default.attributesOfItem(atPath: path)
			if let size = attribute[FileAttributeKey.size] as? NSNumber {
				return size.doubleValue / (1024 * 1024)
			}
		} catch {
			print("Error: \(error)")
		}
		return 0.0
	}
}

extension URL {
	var attributes: [FileAttributeKey : Any]? {
		do {
			return try FileManager.default.attributesOfItem(atPath: path)
		} catch let error as NSError {
			print("FileAttribute error: \(error)")
		}
		return nil
	}

	var fileSize: UInt64 {
		return attributes?[.size] as? UInt64 ?? UInt64(0)
	}

	var fileSizeString: String {
		return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
	}

	var creationDate: Date? {
		return attributes?[.creationDate] as? Date
	}
}
