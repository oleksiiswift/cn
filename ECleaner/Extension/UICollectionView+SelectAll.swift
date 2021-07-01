//
//  UICollectionView+SelectAll.swift
//  ECleaner
//
//  Created by alekseii sorochan on 01.07.2021.
//

import UIKit

extension UICollectionView {
    
    func selectAllItems(in section: Int, first itemIndex: Int = 0, animated: Bool) {
        (itemIndex..<numberOfItems(inSection: section)).compactMap({ (item) -> IndexPath? in
            return IndexPath(item: item, section: section)
        }).compactMap({ $0}).forEach { (indexPath) in
            selectItem(at: indexPath, animated: animated, scrollPosition: [])
        }
    }
    
    func deselectAllItems(in section: Int, first itemIndex: Int = 0, animated: Bool) {
        (itemIndex..<numberOfItems(inSection: section)).compactMap({ (item) -> IndexPath? in
            return IndexPath(item: item, section: section)
        }).compactMap({ $0}).forEach { (indexPath) in
            deselectItem(at: indexPath, animated: animated)
        }
    }
}
