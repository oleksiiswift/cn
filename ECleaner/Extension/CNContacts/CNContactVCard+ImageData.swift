//
//  CNContactVCard+ImageData.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.12.2021.
//

import Contacts

extension CNContactVCardSerialization {
	
	class func dataWithImage(contacts: [CNContact]) throws -> Data {
		var text: String = ""
		for contact in contacts {
			let data = try CNContactVCardSerialization.data(with: [contact])
			var str = String(data: data, encoding: .utf8)!
			
			if let imageData = contact.thumbnailImageData {
				let base64 = imageData.base64EncodedString()
				str = str.replacingOccurrences(of: "END:VCARD", with: "PHOTO;ENCODING=b;TYPE=JPEG:\(base64)\nEND:VCARD")
			}
			text = text.appending(str)
		}
		return text.data(using: .utf8)!
	}
}
