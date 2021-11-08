//
//  ContactsGroupDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.11.2021.
//

import UIKit

class ContactsGroupDataSource: NSObject {
    
    public var contactGroupListViewModel: ContactGroupListViewModel
    
    
//    let cellBackgroundColor: UIColor = UIColor().colorFromHexString("ECF0F6")
//    let cellSelectedBackgroundColor: UIColor =  UIColor().colorFromHexString("D8DFEB")
//    let edgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//    let cornerRadius: CGFloat = 15.0
//    let shadowOpacity: CGFloat = 0.1
//    let shadowRadius: CGFloat = 5.0
    
    
    init(viewModel: ContactGroupListViewModel) {
        self.contactGroupListViewModel = viewModel
    }
}

extension ContactsGroupDataSource {
    
    private func cellConfigure(cell: ContactTableViewCell, at indexPath: IndexPath) {
        
        guard let contact = contactGroupListViewModel.getContact(at: indexPath) else { return }
        
//        cell.backgroundColor = UIColor.clear
//        cell.contentView.backgroundColor = UIColor.orange
        
        cell.updateContactCell(contact)
    }
}

extension ContactsGroupDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.contactGroupListViewModel.numbersOfSections()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactGroupListViewModel.numbersOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contactCell, for: indexPath) as! ContactTableViewCell
        
//        let lastIndexPath = tableView.lastIndexpath()
        
//        cell.addShadowToCellInTableView(lastIndex: lastIndexPath.row, atIndexPath: indexPath)
        self.cellConfigure(cell: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: U.screenWidth, height: 60))
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        // Top corners
//        let maskPathTop = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10.0, height: 10.0))
//        let shapeLayerTop = CAShapeLayer()
//        shapeLayerTop.frame = cell.contentView.bounds
//        shapeLayerTop.path = maskPathTop.cgPath
//
//        //Bottom corners
//        let maskPathBottom = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
//        let shapeLayerBottom = CAShapeLayer()
//        shapeLayerBottom.frame = cell.contentView.bounds
//        shapeLayerBottom.path = maskPathBottom.cgPath
//
//        // All corners
//        let maskPathAll = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 5.0, height: 5.0))
//        let shapeLayerAll = CAShapeLayer()
//        shapeLayerAll.frame = cell.contentView.bounds
//        shapeLayerAll.path = maskPathAll.cgPath
//
//        if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
//            cell.contentView.layer.mask = shapeLayerAll
//        } else if indexPath.row == 0 {
//            cell.contentView.layer.mask = shapeLayerTop
//        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
//            cell.contentView.layer.mask = shapeLayerBottom
//        }
//    }
    
//     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
//
//        cell.backgroundColor = .clear
//        cell.clipsToBounds = false
//
//        if numberOfRows <= 1 {
//            cell.backgroundView = allCardBackgroundView(backgroundColor: cellBackgroundColor)
//            cell.selectedBackgroundView = allCardBackgroundView(backgroundColor: cellSelectedBackgroundColor)
//            return
//        }
//
//        if indexPath.row == 0 {
//            cell.backgroundView = topCardBackgroundView(backgroundColor: cellBackgroundColor)
//            cell.selectedBackgroundView = topCardBackgroundView(backgroundColor: cellSelectedBackgroundColor)
//        } else if indexPath.row + 1 < numberOfRows {
//            cell.backgroundView = centerCardBackgroundView(backgroundColor: cellBackgroundColor)
//            cell.selectedBackgroundView = centerCardBackgroundView(backgroundColor: cellSelectedBackgroundColor)
//        } else if indexPath.row + 1 == numberOfRows {
//            cell.backgroundView = bottomCardBackgroundView(backgroundColor: cellBackgroundColor)
//            cell.selectedBackgroundView = bottomCardBackgroundView(backgroundColor: cellSelectedBackgroundColor)
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let groupCell = cell as? ContactTableViewCell else { return }
        
        let numbersOfRows = tableView.numberOfRows(inSection: indexPath.section)
        
        
        if numbersOfRows <= 1 {
            
            return
        }
        
        if indexPath.row == 0 {
            groupCell.topShadowView.sectionColorsPosition = .top
            
        } else if indexPath.row + 1 < numbersOfRows {
            groupCell.topShadowView.sectionColorsPosition = .central
        } else if indexPath.row + 1 == numbersOfRows {
            groupCell.topShadowView.sectionColorsPosition = .bottom
        }
    }
}


//extension ContactsGroupDataSource {
//
//    private func cardImage(drawMode: PartialCardImageDrawMode, backgroundColor: UIColor) -> PartialCardImage {
//        return PartialCardImage(drawMode: drawMode,
//                                edgeInsets: edgeInsets,
//                                backgroundColor: backgroundColor,
//                                cornerRadius: cornerRadius,
//                                shadowOpacity: shadowOpacity,
//                                shadowRadius: shadowRadius)
//    }
//
//    func allCardBackgroundView(backgroundColor: UIColor) -> UIView? {
//        return CardBackgroundImageView(cardImage: cardImage(drawMode: .all, backgroundColor: backgroundColor))
//    }
//
//    func topCardBackgroundView(backgroundColor: UIColor) -> UIView? {
//        return CardBackgroundImageView(cardImage: cardImage(drawMode: .top, backgroundColor: backgroundColor))
//    }
//
//    func centerCardBackgroundView(backgroundColor: UIColor) -> UIView? {
//        return CardBackgroundImageView(cardImage: cardImage(drawMode: .center, backgroundColor: backgroundColor))
//    }
//
//    func bottomCardBackgroundView(backgroundColor: UIColor) -> UIView? {
//        return CardBackgroundImageView(cardImage: cardImage(drawMode: .bottom, backgroundColor: backgroundColor))
//    }
//}




