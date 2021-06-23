//
//  UpdateContentDataBaseListener.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.06.2021.
//

import Foundation

protocol UpdateContentDataBaseListener {
    func getPhotoLibraryCount(count: Int)
    func getVideoCount(count: Int)
    func getContactsCount(count: Int)
}
