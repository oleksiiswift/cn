//
//  DropDownMenuViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 05.07.2021.
//

import UIKit

class DropDownMenuViewController: UIViewController {
    
    var menuSectionItems = [DropDownOptionsMenuItem]() {
        didSet {
            self.calculateMenuContentSize()
        }
    }
    
    private weak var tableView: UITableView?
    
    var delegate: SelectDropDownMenuDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .popover
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UITableView(frame: .zero, style: .plain)
        self.tableView = view as? UITableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
}

extension DropDownMenuViewController {
    
    private func setupUI() {}
    
    private func setupTableView() {
        
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.separatorStyle = .none
        self.tableView?.isScrollEnabled = false
        self.tableView?.backgroundColor = theme.dropDownMenuBackgroundColor
        self.tableView?.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        self.tableView?.register(UINib(nibName: C.identifiers.xibs.dropDownCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.dropDownCell)
        
        if let optionTableView = self.tableView {
            self.view.bringSubviewToFront(optionTableView)
        }
    }
    
    private func configure(_ cell: DropDownMenuTableViewCell, at indexPath: IndexPath) {
        
        guard let tableView = self.tableView else { return }
        
        let rowPosition = self.checkIndexPosition(from: indexPath, numberOfRows: tableView.numberOfRows(inSection: indexPath.section))
		cell.configure(with: menuSectionItems[indexPath.row], row: rowPosition)
    }
    
    private func calculateMenuContentSize() {
		let itemsCount = CGFloat(menuSectionItems.compactMap({$0}).count)
        var viewWidth: CGFloat = 150
        let viewHeight: CGFloat = itemsCount * 44
		let flatItems = menuSectionItems.compactMap({$0})
        for item in flatItems {
            if item.sizeForFutureText().width + 90 > viewWidth {
                viewWidth = item.sizeForFutureText().width + 90
            }
        }
        preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
    }
}

extension DropDownMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuSectionItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menuSectionItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.dropDownCell, for: indexPath) as! DropDownMenuTableViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedItem = menuSectionItems[indexPath.row]
        self.dismiss(animated: true) {
            self.delegate?.selectedItemListViewController(self, didSelectItem: selectedItem.menuItem)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension DropDownMenuViewController {
    
    private func checkIndexPosition(from indexPath: IndexPath, numberOfRows: Int) -> RowPosition {
        
        if indexPath.row == 0 {
            return .top
        } else if indexPath.row + 1 < numberOfRows {
            return .middle
        } else if indexPath.row + 1 == numberOfRows {
            return .bottom
        } else {
            return .none
        }
    }
}
