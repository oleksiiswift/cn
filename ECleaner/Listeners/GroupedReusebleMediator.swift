//
//  GroupedReusebleMediator.swift
//  ECleaner
//
//  Created by alekseii sorochan on 01.07.2021.
//

import Foundation

class GroupedReusebleMediator {
    
    
    class var instance: GroupedReusebleMediator {
        struct Static {
            static let instance: GroupedReusebleMediator = GroupedReusebleMediator()
        }
        return Static.instance
    }
    
    private var listener: GroupedReusebleListener?
    private init() {}
    
    func setListener(listener: GroupedReusebleListener) {
        self.listener = listener
    }
    
    func updateSeleAllButtonState(index: Int, selectAllState: Bool) {
        listener?.setSelectAllButtonState(index: index, isSelectAllState: selectAllState)
    }
}
