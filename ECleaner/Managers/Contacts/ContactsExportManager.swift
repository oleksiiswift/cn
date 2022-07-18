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
	
	private var fileManager = ECFileManager()
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
				if let tempDirectory = self.fileManager.getDirectoryURL(.temp) {
					let fileURL = tempDirectory.appendingPathComponent(Localization.Main.Title.contactsTitle).appendingPathExtension(CNContactFileType.vcf.extensionName)
					
					if fileManager.isFileExiest(at: fileURL) {
						fileManager.deletefile(at: fileURL)
					}
					try data.write(to: fileURL)
					completionHandler(fileURL)
				} else {
					completionHandler(nil)
				}
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
			
			if let tempDirectory = self.fileManager.getDirectoryURL(.temp) {
				let fileURL = tempDirectory.appendingPathComponent(Localization.Main.Title.contactsTitle).appendingPathExtension(CNContactFileType.csv.extensionName)
				
				if fileManager.isFileExiest(at: fileURL) {
					fileManager.deletefile(at: fileURL)
				}
				
				try vCardData.write(to: fileURL)
				completionHandler(fileURL)
			} else {
				completionHandler(nil)
			}
		} catch {
			debugPrint(error.localizedDescription)
			completionHandler(nil)
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

enum ContactsBackupStatus {
	case initial
	case prepare
	case empty
	case processing
	case filesCreated(destinationURL: URL?)
	case archived(url: URL)
	case error(error: Error)
}

extension ContactsExportManager {
	
	public func contactsBackup(completionHandler: @escaping (_ status: ContactsBackupStatus) -> Void) {
		
		self.setStatus(.prepare)
		
		Utils.delay(0.5) {
			
			self.prepareForBackUp {
				
				Utils.delay(0.5) {
					
				    self.setStatus(.processing)
					
					self.filesCreateSeparated { status in
						
						switch status {
							case .empty:
								completionHandler(.empty)
							case .filesCreated(destinationURL: let directory):
								
								self.setStatus(.filesCreated(destinationURL: directory))
								
								if let archivedDirectory = directory {
									
									self.createZip(from: archivedDirectory) { status in
										
										switch status {
											case .archived(let url):
												self.fileManager.copyFileTempDirectory(from: url, with: Localization.Main.Title.contactsTitle.lowercased(), file: .zip) { url in
													if let url = url {
														completionHandler(.archived(url: url))
													} else {
														let error = ErrorHandler.ShareError.errorSavedFile
														completionHandler(.error(error: error))
													}
													self.fileManager.deleteAllFiles(at: .systemTemp) {}
												}
											case .error(let error):
												completionHandler(.error(error: error))
											default:
												return
										}
									}
								}
							default:
								return
						}
					}
				}
			}
		}
	}
	
	private func prepareForBackUp(completionHandler: @escaping () -> Void) {
		
		let group = DispatchGroup()
		let queue = DispatchQueue.global(qos: .background)
		
		queue.async {
			group.enter()
			
			self.fileManager.deleteAllFiles(at: .contactsArcive) {
				group.leave()
			}
			
			group.enter()
			self.fileManager.deleteAllFiles(at: .temp) {
				group.leave()
			}
			
			group.notify(queue: DispatchQueue.main) {
				completionHandler()
			}
		}
	}
	
	private func filesCreateSeparated(completionHandler: @escaping (_ status: ContactsBackupStatus) -> Void) {
		
		let pathExtension = CNContactFileType.vcf.extensionName
		
		self.contactsManager.getAllContacts { contacts in
			
			if !contacts.isEmpty {
				
				let dispatchGroup = DispatchGroup()
				let dispatchQueue = DispatchQueue.global(qos: .background)
				let dispatchSemaphore = DispatchSemaphore(value: 5)
				
				let contactsArchiveDirectory = self.fileManager.getDirectoryURL(.contactsArcive)
				
				var contactsPosition = 0
				
				for contact in contacts {
					
					dispatchGroup.enter()
					
					let contactFullName = CNContactFormatter.string(from: contact, style: .fullName)
					
					do {
						var data = Data()
						try data = CNContactVCardSerialization.dataWithImage(contacts: [contact])
						
						do {
							var newName: String = ""
							if let name = contactFullName,
							   let fileURL = contactsArchiveDirectory?.appendingPathComponent(name).appendingPathExtension(pathExtension) {
								
								var counter = 0
								var writebleURL = fileURL
								
								while self.fileManager.isFileExiest(at: writebleURL) {
									counter += 1
									newName = String("\(name) (\(counter))")
									guard let newURL = contactsArchiveDirectory?.appendingPathComponent(newName).appendingPathExtension(pathExtension) else { return }
									writebleURL = newURL
								}
								try data.write(to: writebleURL)
								contactsPosition += 1
								debugPrint(contactsPosition, name)
								ContactsBackupUpdateMediator.instance.updateProgres(with: name, currentIndex: contactsPosition, total: contacts.count)
								if contacts.count < 1000 {
									usleep(1000) //will sleep
								} else if contacts.count < 10000{
									usleep(100) //will sleep
								}
							}
						} catch {
							debugPrint(error.localizedDescription)
						}
					} catch {
						debugPrint(error.localizedDescription)
					}
					
					dispatchSemaphore.signal()
					dispatchGroup.leave()
				}
				
				dispatchGroup.notify(queue: dispatchQueue) {
					completionHandler(.filesCreated(destinationURL: contactsArchiveDirectory))
				}
			} else {
				completionHandler(.empty)
			}
		}
	}

	private func createZip(from directory: URL, completionHandler: @escaping (_ status: ContactsBackupStatus) -> Void) {
		
		let coordinator = NSFileCoordinator()
		
		let zipIntent = NSFileAccessIntent.readingIntent(with: directory, options: [.forUploading])
		
		coordinator.coordinate(with: [zipIntent], queue: .main) { errorQ in
			if let error = errorQ {
				completionHandler(.error(error: error))
			} else {
				let zipURL = zipIntent.url
				completionHandler(.archived(url: zipURL))
			}
			
			self.fileManager.deleteAllFiles(at: .contactsArcive) {}
		}
	}
	
	private func setStatus(_ status: ContactsBackupStatus) {
		ContactsBackupUpdateMediator.instance.updateStatus(with: status)
	}
}
