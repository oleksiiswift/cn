//
//  UpdateContentDataBaseListener.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.06.2021.
//

import Foundation

protocol UpdateContentDataBaseListener {
    func getPhotoLibraryCount(count: Int, calculatedSpace: Int64)
    func getVideoCount(count: Int, calculatedSpace: Int64)
    func getContactsCount(count: Int)
}
