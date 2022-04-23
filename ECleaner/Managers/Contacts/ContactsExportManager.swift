//
//  ContactsExportManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.12.2021.
//

import Contacts

enum CNContactFileType {
	case vcf
	case csv
	
	var extensionName: String {
		switch self {
			case .vcf:
				return "vcf"
			case .csv:
				return "csv"
		}
	}
}

class ContactsExportManager {
	
	static let shared: ContactsExportManager = {
		let instance = ContactsExportManager()
		return instance
	}()
	
	private var fileManager = FileManager.default
	private var contactsManager = ContactsManager.shared
	
}


	//	MARK: - CONTACTS EXPORT -
extension ContactsExportManager {
	
		/// export `[CNContacts] TO VCF`
	public func vcfContactsExportAll(_ completion: @escaping (_ fileURL: URL?) -> Void) {
		
		contactsManager.getAllContacts { contacts in
			self.exporContactsAsVCF(contacts) { fileURL in
				completion(fileURL)
			}
		}
	}
	
	public func vcfContactsExport(contacts: [CNContact],_ completion: @escaping (_ fileURL: URL?) -> Void) {
		self.exporContactsAsVCF(contacts) { fileURL in
			completion(fileURL)
		}
	}
	
		/// export `[CNContacts] TO CSV`
	public func csvContactsExportAll(_ completion: @escaping (_ fileURL: URL?) -> Void) {
		
		contactsManager.getAllContacts { contacts in
			self.exportContactsAsCSV(contacts) { fileURL in
				completion(fileURL)
			}
		}
	}
	
	public func csvContactsExport(contacts: [CNContact],_ completion: @escaping (_ fileURL: URL?) -> Void) {
		self.exportContactsAsCSV(contacts) { fileURL in
			completion(fileURL)
		}
	}
	
		/// `Convert [CNContacts] TO VCF`
	private func exporContactsAsVCF(_ contacts: [CNContact], completionHandler: @escaping (_ fileURL: URL?) -> Void) {
		
		do {
			var data = Data()
			try data = CNContactVCardSerialization.dataWithImage(contacts: contacts)
			do {
				let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
				let fileURL = documentDirectory.appendingPathComponent("someName").appendingPathExtension(CNContactFileType.vcf.extensionName)
				if self.fileManager.fileExists(atPath: fileURL.absoluteString) {
					try self.fileManager.removeItem(at: fileURL)
				}
				try data.write(to: fileURL)
				completionHandler(fileURL)
			} catch {
				completionHandler(nil)
				debugPrint(error.localizedDescription)
			}
		} catch {
			completionHandler(nil)
			debugPrint(error.localizedDescription)
		}
	}
	
		/// `Convert CSV TO [CNContact]`
	private func exportContactsAsCSV(_ contacts: [CNContact], completionHandler: @escaping (_ fileURL: URL?) -> Void) {
		
		var vCardData = Data()
		
		do {
			try vCardData = CNContactVCardSerialization.data(with: contacts)
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
			let fileURL = documentDirectory.appendingPathComponent("someName").appendingPathExtension(CNContactFileType.csv.extensionName)
			if fileManager.fileExists(atPath: fileURL.absoluteString) {
				try fileManager.removeItem(at: fileURL)
			}
			try vCardData.write(to: fileURL)
			completionHandler(fileURL)
		} catch {
			debugPrint(error.localizedDescription)
		}
	}
}


	//	MARK: - CONTACTS ARCHIVE -
extension ContactsExportManager {
	
		/// `archive`
	public func archiveContacts(contacts: [CNContact], completionHandler: @escaping (_ result: Data?) -> Void) {
		do {
			let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: contacts, requiringSecureCoding: true)
			completionHandler(encodedData)
		} catch {
			completionHandler(nil)
		}
	}
	
		///  `unarchive`
	public func unarchiveConverter(data: Data, completionHandler: @escaping (_ result: [CNContact]) -> Void) {
		do {
			let decodedData: Any? = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [CNContact]
			if let contacts: [CNContact] = decodedData as? [CNContact] {
				completionHandler(contacts)
			} else {
				completionHandler([])
			}
		} catch {
			completionHandler([])
		}
	}
}
