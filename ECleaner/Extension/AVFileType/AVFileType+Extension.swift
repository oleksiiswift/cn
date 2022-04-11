//
//  AVFileType+Extension.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.04.2022.
//

import Foundation
import AVFoundation
import MobileCoreServices

extension AVFileType {
	
	var fileExtension: String {
		if #available(iOS 14.0, *) {
			if let utType = UTType(self.rawValue) {
							print("utType.preferredMIMEType: \(String(describing: utType.preferredMIMEType))")
							return utType.preferredFilenameExtension ?? "None"
						}
						return "None"
		} else {
			if let fileExtension = UTTypeCopyPreferredTagWithClass(self as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() {
				return fileExtension as String
			}
			return "None"
		}
	}
}
