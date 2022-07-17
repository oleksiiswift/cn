//
//  ShareManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 20.11.2021.
//

import Foundation
import MessageUI
import Contacts
import Photos

class ShareManager {
    
    static let shared: ShareManager = {
        let instance = ShareManager()
        return instance
    }()
    
    private var fileManager = ECFileManager()
    private var contactsExportManager = ContactsExportManager.shared
	private var photoManager = PhotoManager.shared
}

extension ShareManager {
    
    public func shareAllContacts(_ exportType: ExportContactsAvailibleFormat,_ comtpletionHandler: @escaping (Bool) -> Void) {
        switch exportType {
            case .vcf:
                self.shareAllVCFContacts { create in
                    comtpletionHandler(create)
                }
            case .csv:
                self.shareAllCSVContacts { create in
                    comtpletionHandler(create)
                }
            case .none:
                return
        }
    }
    
    private func shareAllVCFContacts(_ completion: @escaping(Bool) -> Void) {
		contactsExportManager.vcfContactsExportAll { fileURL in
            P.hideIndicator()
            if let url = fileURL {
                completion(true)
                self.shareVCFContacts(from: url)
            }
        }
    }
    
    private func shareAllCSVContacts(_ completion: @escaping(Bool) -> Void) {
		contactsExportManager.csvContactsExportAll { fileURL in
            P.hideIndicator()
            if let url = fileURL {
                completion(true)
                self.shareCSVContacts(from: url)
            }
        }
    }
    
    public func shareContacts(_ contacts: [CNContact], of format: ExportContactsAvailibleFormat,_ completionHandler: @escaping (Bool) -> Void) {
        
        switch format {
            case .vcf:
				contactsExportManager.vcfContactsExport(contacts: contacts) { fileURL in
                    P.hideIndicator()
                    if let url = fileURL {
                        completionHandler(true)
                        self.shareVCFContacts(from: url)
                    } else {
                        completionHandler(false)
                    }
                }
            case .csv:
				contactsExportManager.csvContactsExport(contacts: contacts) { fileURL in
                    P.hideIndicator()
                    if let url = fileURL {
                        completionHandler(true)
						self.shareCSVContacts(from: url)
                    } else {
                        completionHandler(false)
                    }
                }
            default:
                return
        }
    }
    
    private func shareVCFContacts(from fileURL: URL) {
        shareContacts(of: .vcf, with: fileURL)
    }
    
    private func shareCSVContacts(from fileURL: URL) {
        shareContacts(of: .csv, with: fileURL)
    }
    
    private func shareContacts(of format: FileFormat, with url: URL) {
        
		self.fileManager.copyFileTempDirectory(from: url, with: Localization.Main.Title.contactsTitle, file: format) { url in
            
            if let tempURL = url, self.fileManager.isFileExiest(at: tempURL) {
                
                let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: [])
                activityViewController.completionWithItemsHandler = { (_, _, _, _) -> Void in
                    self.fileManager.deletefile(at: tempURL)
                }
                
                if !MFMailComposeViewController.canSendMail() {
                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.mail]
                }
                U.UI {
                    if let topController = topController() {
                        topController.present(activityViewController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension ShareManager {
	
	public func shareCompressedVideFile(with url: URL, completion: @escaping (() -> Void)) {
		
		let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
		activityViewController.completionWithItemsHandler = { (_, _, _, _) -> Void in
			self.fileManager.deletefile(at: url)
			completion()
		}
		
		if !MFMailComposeViewController.canSendMail() {
			activityViewController.excludedActivityTypes = [UIActivity.ActivityType.mail]
		}
		
		U.UI {
			if let topController = topController() {
				topController.present(activityViewController, animated: true, completion: nil)
			}
		}
	}
}

extension ShareManager {
	
	public func shareVideoFile(from phasset: PHAsset, completionHandler: @escaping (() -> Void)) {
		
		P.showIndicator()
		U.delay(1) {
			self.photoManager.getPhassetShareUrl(phasset) { sharedURL, name in
				P.hideIndicator()
				if let sharedURL = sharedURL, let name = name {
					self.shareVideoFrom(url: sharedURL, name: name) {}
				}
			}
		}
	}
	
	private func shareVideoFrom(url: URL, name: String, completionHandler: @escaping (() -> Void)) {
	
		DispatchQueue.main.async {
			let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
	
			activityViewController.completionWithItemsHandler = { (_, _, _, _) -> Void in
				completionHandler()
			}
			
			activityViewController.excludedActivityTypes = [UIActivity.ActivityType.saveToCameraRoll]
			if !MFMailComposeViewController.canSendMail() {
				activityViewController.excludedActivityTypes = [UIActivity.ActivityType.mail]
			}
		
			if let topController = topController() {
				topController.present(activityViewController, animated: true, completion: nil)
			}
		}
	}
}
