//
//  CellBlock 52.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.11.2021.
//

import Foundation
import UIKit
//extension ContactsManagerOLD {
//
////    use only with know country
//    func phonesValidatibg(_ contact: CNContact) -> Int {
//
//        let numbers = contact.phoneNumbers.compactMap( { phoneNumber -> String? in
//            guard let label = phoneNumber.label else { return nil}
//            return phoneNumber.value.stringValue
//        })
//        let phoneNumbers = self.phoneNumberKit.parse(numbers, ignoreType: true, shouldReturnFailedEmptyNumbers: false)
//
//        return phoneNumbers.count
//    }
//}


//extension ContactsManagerOLD {
//    
//    
//    func mergeAllDuplicates(_ duplicates: [CNContact]) -> CNContact {
//        
//        var givenName: [String] = []
//        var familyName: [String] = []
//        var organizationName: [String] = []
//        var notes: [String] = []
//        
//        var phoneNumbers: [CNLabeledValue<CNPhoneNumber>] = []
//        var emailAddresses: [CNLabeledValue<NSString>] = []
//        var postalAddresses: [CNLabeledValue<CNPostalAddress>] = []
//        var urlAddresses: [CNLabeledValue<NSString>] = []
//        
//        
//        for contact in duplicates {
//            givenName.append(contact.givenName)
//            familyName.append(contact.familyName)
//            organizationName.append(contact.organizationName)
//            notes.append(contact.note)
//            
//            contact.phoneNumbers.forEach { phoneNumbers.append($0) }
//            contact.emailAddresses.forEach { emailAddresses.append($0) }
//            contact.postalAddresses.forEach { postalAddresses.append($0) }
//            contact.urlAddresses.forEach { urlAddresses.append($0) }
//        }
//        
//        let newContact = CNMutableContact()
//        newContact.givenName = givenName.bestElement ?? ""
//        newContact.familyName = familyName.bestElement ?? ""
//        newContact.organizationName = organizationName.bestElement ?? ""
//        newContact.note = notes.joined(separator: "\n")
//        
//        newContact.phoneNumbers = phoneNumbers
//        newContact.emailAddresses = emailAddresses
//        newContact.postalAddresses = postalAddresses
//        newContact.urlAddresses = urlAddresses
//        
//        return newContact
//    }
//}


//extension ContactsManagerOLD {
//
//    public func specialContacts() {
//        
//        
//        lazy var contacts: [CNContact] = {
//            let contactStore = CNContactStore()
////            let keysToFetch = [
////                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
////                CNContactEmailAddressesKey,
////                CNContactPhoneNumbersKey,
////                CNContactImageDataAvailableKey,
////                CNContactThumbnailImageDataKey] as [Any]
//            // Get all the containers
//            var allContainers: [CNContainer] = []
//            do {
//                allContainers = try contactStore.containers(matching: nil)
//            } catch {
//                print("Error fetching containers")
//            }
//
//            var results: [CNContact] = []
//
//            // Iterate all containers and append their contacts to our results array
//            for container in allContainers {
//                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
//
//                do {
//                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: self.fetchingKeys)
//                    results.append(contentsOf: containerResults)
//                } catch {
//                    print("Error fetching results for container")
//                }
//            }
//
//            return results
//        }()
//        
//        
//        
//        debugPrint(contacts)
//    }
//}

class CompareImage {

    /// Value in range 0...100 %
    typealias Percentage = Float

    // See: https://github.com/facebookarchive/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage%2BCompare.m
    public func compare(tolerance: Percentage, expected: Data, observed: Data) -> Bool {
        guard let expectedUIImage = UIImage(data: expected), let observedUIImage = UIImage(data: observed) else {
            return false
        }
        guard let expectedCGImage = expectedUIImage.cgImage, let observedCGImage = observedUIImage.cgImage else {
            return false
        }
        guard let expectedColorSpace = expectedCGImage.colorSpace, let observedColorSpace = observedCGImage.colorSpace else {
            return false
        }
        if expectedCGImage.width != observedCGImage.width || expectedCGImage.height != observedCGImage.height {
            return false
        }
        let imageSize = CGSize(width: expectedCGImage.width, height: expectedCGImage.height)
        let numberOfPixels = Int(imageSize.width * imageSize.height)

        // Checking that our `UInt32` buffer has same number of bytes as image has.
        let bytesPerRow = min(expectedCGImage.bytesPerRow, observedCGImage.bytesPerRow)
        assert(MemoryLayout<UInt32>.stride == bytesPerRow / Int(imageSize.width))

        let expectedPixels = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfPixels)
        let observedPixels = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfPixels)

        let expectedPixelsRaw = UnsafeMutableRawPointer(expectedPixels)
        let observedPixelsRaw = UnsafeMutableRawPointer(observedPixels)

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let expectedContext = CGContext(data: expectedPixelsRaw, width: Int(imageSize.width), height: Int(imageSize.height),
                                              bitsPerComponent: expectedCGImage.bitsPerComponent, bytesPerRow: bytesPerRow,
                                              space: expectedColorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            expectedPixels.deallocate()
            observedPixels.deallocate()
            return false
        }
        guard let observedContext = CGContext(data: observedPixelsRaw, width: Int(imageSize.width), height: Int(imageSize.height),
                                              bitsPerComponent: observedCGImage.bitsPerComponent, bytesPerRow: bytesPerRow,
                                              space: observedColorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            expectedPixels.deallocate()
            observedPixels.deallocate()
            return false
        }

        expectedContext.draw(expectedCGImage, in: CGRect(origin: .zero, size: imageSize))
        observedContext.draw(observedCGImage, in: CGRect(origin: .zero, size: imageSize))

        let expectedBuffer = UnsafeBufferPointer(start: expectedPixels, count: numberOfPixels)
        let observedBuffer = UnsafeBufferPointer(start: observedPixels, count: numberOfPixels)

        var isEqual = true
        if tolerance == 0 {
            isEqual = expectedBuffer.elementsEqual(observedBuffer)
        } else {
            // Go through each pixel in turn and see if it is different
            var numDiffPixels = 0
            for pixel in 0 ..< numberOfPixels where expectedBuffer[pixel] != observedBuffer[pixel] {
                // If this pixel is different, increment the pixel diff count and see if we have hit our limit.
                numDiffPixels += 1
                let percentage = 100 * Float(numDiffPixels) / Float(numberOfPixels)
                if percentage > tolerance {
                    isEqual = false
                    break
                }
            }
        }

        expectedPixels.deallocate()
        observedPixels.deallocate()

        return isEqual
    }
}
