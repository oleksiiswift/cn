//
//  TableView+IndexPath.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.11.2021.
//

import UIKit

extension UITableView {
    func lastIndexpath() -> IndexPath {
        let section = max(numberOfSections - 1, 0)
        let row = max(numberOfRows(inSection: section) - 1, 0)

        return IndexPath(row: row, section: section)
    }
}
