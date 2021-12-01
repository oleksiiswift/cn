//
//  ErrorHandler.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.11.2021.
//
import Foundation
import UIKit

class ErrorHandler {
    
    static let shared: ErrorHandler = {
        let instance = ErrorHandler()
        return instance
    }()
    
    enum DeleteError {
        case errorDeleteContact
        case errorDeleteContacts
    }
    
    enum MeergeError {
        case errorMergeContact
        case errorMergeContacts
        case mergeWithErrors
    }
    
    enum LoadError {
        case errorLoadContacts
        case errorCreateExportFile
    }
    
    
    private func deleteErrorForKey(_ error: DeleteError) -> String {
        switch error {
            case .errorDeleteContact:
                return "cant delete contact"
            case .errorDeleteContacts:
                return "cant delete contacts"
        }
    }
    
    private func mergeErrorForKey(_ error: MeergeError) -> String {
        switch error {
            case .errorMergeContact:
                return "error merge contact"
            case .errorMergeContacts:
                return "error merge contacts"
            case .mergeWithErrors:
                return "merge with errors"
        }
    }
    
    private func loadErrorForKey(_ error: LoadError) -> String {
        switch error {
            case .errorLoadContacts:
                return "error loading contacts"
            case .errorCreateExportFile:
                return "error create export file"
        }
    }
}

extension ErrorHandler {
    
    public func showDeleteAlertError(_ errorType: DeleteError) {
        let alertTitle = "Error"
        let alertAction = UIAlertAction(title: "ok", style: .default)
        A.showAlert(alertTitle, message: deleteErrorForKey(errorType), actions: [alertAction], withCancel: false, completion: nil)
    }
    
    public func showLoadAlertError(_ errorType: LoadError) {
        let alertTitle = "Error"
        A.showAlert(alertTitle, message: loadErrorForKey(errorType), actions: [], withCancel: false, completion: nil)
    }
    
    public func showMergeAlertError(_ errorType: MeergeError, completion: (() -> Void)? = nil) {
        let alertTitle = "Error"
        A.showAlert(alertTitle, message: mergeErrorForKey(errorType), actions: [], withCancel: false) {
            completion?()
        }
    }
}
