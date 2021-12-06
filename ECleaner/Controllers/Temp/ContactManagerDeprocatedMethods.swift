////
////  ContactManagerDeprocatedMethods.swift
////  ECleaner
////
////  Created by alexey sorochan on 29.11.2021.
////
//
//import Foundation
//import Contacts
//
////extension ContactsManagerOLD {
////
////        /// THIS METHODS NOT IN USE ! DEPRICATED MEDODS
////        /// SEARCH PROCESS IS USE MORE TIME ! A.S.
////
////    private func smartNamesDuplicated(_ contacts: [CNContact], completionHandler: @escaping ([CNContact]) -> Void) {
////
////        var duplicates: [CNContact] = []
////
////        for i in 0...contacts.count - 1 {
////            debugPrint("name duplicate index: \(i)")
////            if duplicates.contains(contacts[i]) {
////                continue
////            }
////            let contact = contacts[i]
////            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contacts[i]}).filter({$0.givenName.removeWhitespace() + $0.familyName.removeWhitespace() == contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace()}) //.filter({$0.familyName == contact.familyName})
////
////            duplicatedContacts.forEach({
////                debugPrint("each")
////                if !duplicates.contains(contact) {
////                    debugPrint(contact)
////                    duplicates.append(contact)
////                }
////
////                if !duplicates.contains($0) {
////                    debugPrint($0)
////                    duplicates.append($0)
////                }
////            })
////        }
////
////        completionHandler(duplicates)
////    }
////
////        /// `names duplicated group`
////    private func smartNamesDuplicatesGroup(_ contacts: [CNContact], completionHandler: @escaping ([ContactsGroup]) -> Void) {
////        var group: [ContactsGroup] = []
////
////        for contact in contacts {
////            debugPrint("names group index: \(String(describing: contacts.firstIndex(of: contact)))")
////            if group.filter({$0.name.removeWhitespace().lowercased() == contact.givenName.removeWhitespace().lowercased() + contact.familyName.removeWhitespace().lowercased()}).count == 0 {
////                let countryIdentifier = self.getRegionIdentifier(from: contact)
////                group.append(ContactsGroup(name: contact.givenName.removeWhitespace().lowercased() + contact.familyName.removeWhitespace().lowercased(), contacts: [], groupType: .duplicatedContactName, countryIdentifier: countryIdentifier))
////            }
////        }
////
////        for contact in contacts {
////            debugPrint("extra filer index: \(String(describing: contacts.firstIndex(of: contact)))")
////            group.filter({$0.name.removeWhitespace().lowercased() == contact.givenName.removeWhitespace().lowercased() + contact.familyName.removeWhitespace().lowercased()})[0].contacts.append(contact)
////        }
////
////        group.forEach({ $0.contacts = self.esctimateBestContactIn($0.contacts )})
////
////        completionHandler(group)
////    }
////}
//
//extension ContactsManagerOLD {
//    
//        /// processing is to long -> depricated
//    private func namesDuplicatedDepricated(_ contacts: [CNContact], completionHandler: @escaping ([CNContact]) -> Void) {
//        
//        var duplicates: [CNContact] = []
//        
//        for i in 0...contacts.count - 1 {
//            debugPrint("name duplicate index: \(i)")
//            if duplicates.contains(contacts[i]) {
//                continue
//            }
//            let contact = contacts[i]
//            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contacts[i]}).filter({$0.givenName.removeWhitespace() + $0.familyName.removeWhitespace() == contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace()}) //.filter({$0.familyName == contact.familyName})
//            
//            duplicatedContacts.forEach({
//                
//                let name = $0.givenName.removeWhitespace() + $0.familyName.removeWhitespace() + $0.middleName.removeWhitespace()
//                
//                guard !name.isEmpty else { return }
//                
//                debugPrint("each")
//                if !duplicates.contains(contact) {
//                    debugPrint(contact)
//                    duplicates.append(contact)
//                }
//                
//                if !duplicates.contains($0) {
//                    debugPrint($0)
//                    duplicates.append($0)
//                }
//            })
//        }
//        completionHandler(duplicates)
//    }
//    
//        /// `names duplicated group`
//    private func namesDuplicatesGroupDepricated(_ contacts: [CNContact], completionHandler: @escaping ([ContactsGroup]) -> Void) {
//        var group: [ContactsGroup] = []
//        
//        for contact in contacts {
//            debugPrint("names group index: \(String(describing: contacts.firstIndex(of: contact)))")
//            if group.filter({$0.name.removeWhitespace() == contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace()}).count == 0 {
//                let itentifier = self.getRegionIdentifier(from: contact)
//                group.append(ContactsGroup(name: contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace(), contacts: [], groupType: .duplicatedContactName, countryIdentifier: itentifier))
//            }
//        }
//        
//        for contact in contacts {
//            debugPrint("extra filer index: \(String(describing: contacts.firstIndex(of: contact)))")
//            group.filter({$0.name.removeWhitespace() == contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace()})[0].contacts.append(contact)
//        }
//        
//        group.forEach({ $0.contacts = self.esctimateBestContactIn($0.contacts )})
//        
//        completionHandler(group)
//    }
//    
//    
//    private func phoneDuplicatedGroup(_ contacts: [CNContact], completionHandler: @escaping ([ContactsGroup]) -> Void) {
//        
//        var group: [ContactsGroup] = []
//        var phoneNumbers: [String] = []
//        
//        for contact in contacts {
//            debugPrint("group phone index: \(String(describing: contacts.firstIndex(of: contact)))")
//            let countryIdentifier = self.getRegionIdentifier(from: contact)
//            for phone in contact.phoneNumbers {
//                let stringValue = phone.value.stringValue
//                if !phoneNumbers.contains(stringValue) {
//                    phoneNumbers.append(stringValue)
//                    group.append(ContactsGroup(name: stringValue, contacts: [], groupType: .duplicatedPhoneNumnber, countryIdentifier: countryIdentifier))
//                }
//            }
//        }
//        
//        for number in phoneNumbers {
//            let contacts = contacts.filter({ $0.phoneNumbers.map({ $0.value.stringValue }).contains(number) })
//            debugPrint("fileter phone number \(number)")
//            group.filter({ $0.name == number })[0].contacts.append(contentsOf: contacts)
//        }
//        
//        group.forEach({ $0.contacts = self.esctimateBestContactIn($0.contacts )})
//        
//        completionHandler(group)
//    }
//    
//    private func phoneDuplicatesDepricate(_ contacts: [CNContact], completionHandler: @escaping ([CNContact]) -> Void) {
//        var duplicates: [CNContact] = []
//        
//        let filteredContacts = contacts.filter({ $0.phoneNumbers.count != 0})
//        
//        for i in 0...filteredContacts.count - 1 {
//            debugPrint("phone duplicates index: \(i)")
//            if duplicates.contains(contacts[i]) {
//                continue
//            }
//            
//            let phones: [String] = filteredContacts[i].phoneNumbers.map({$0.value.stringValue})
//            let duplicatedContacts: [CNContact] = filteredContacts.filter({$0 != filteredContacts[i]}).filter({
//                return $0.phoneNumbers.map({ $0.value.stringValue}).contains(phones)
//            })
//            
//            duplicatedContacts.forEach({
//                debugPrint("for each number")
//                if !duplicates.contains(filteredContacts[i]){
//                    debugPrint(filteredContacts[i])
//                    duplicates.append(filteredContacts[i])
//                }
//                if !duplicates.contains($0){
//                    debugPrint($0)
//                    duplicates.append($0)
//                }
//            })
//        }
//        completionHandler(duplicates)
//    }
//    
//    private func emailDuplicates(_ contacts: [CNContact], completionHandler: @escaping ([CNContact]) -> Void) {
//        
//        var duplicates: [CNContact] = []
//        
//        for i in 0...contacts.count - 1 {
//            debugPrint("email -> \(i)")
//            let contact = contacts[i]
//            
//            if duplicates.contains(contact) {
//                continue
//            }
//            
//            let emailList: [String] = contact.emailAddresses.map({ $0.value as String})
//            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contact}).filter({
//                return $0.emailAddresses.map({ $0.value as String}).contains(emailList)
//            })
//            
//            duplicatedContacts.forEach({
//                debugPrint("compare email")
//                if !duplicates.contains(contact) {
//                    duplicates.append(contact)
//                }
//                if !duplicates.contains($0) {
//                    duplicates.append($0)
//                }
//            })
//        }
//        completionHandler(duplicates)
//    }
//    
//    private func emailListDuplicatedGroup(_ contacts: [CNContact], completionHandler: @escaping ([ContactsGroup]) -> Void) {
//        
//        var group: [ContactsGroup] = []
//        var emailList: [String] = []
//        
//        for contact in contacts {
////            TODO: email clean position for deeep grouping
//            let identifier = self.getRegionIdentifier(from: contact)
//            debugPrint(contacts.firstIndex(of: contact) ?? "hell")
//            for email in contact.emailAddresses {
//                if emailList.contains(email.value as String) {
//                    emailList.append(email.value as String)
//                    group.append(ContactsGroup(name: email.value as String, contacts: [], groupType: .duplicatedEmail, countryIdentifier: identifier))
//                }
//            }
//        }
//        
//        for email in emailList {
//            let contacts = contacts.filter({$0.emailAddresses.map({ $0.value as String}).contains(email)})
//            group.filter({$0.name == email})[0].contacts.append(contentsOf: contacts)
//        }
//        completionHandler(group)
//    }
//}
