//
//  PhotoOperationQueue.swift
//  ECleaner
//
//  Created by alekseii sorochan on 21.07.2021.
//

import Foundation

class AssetsOperationQueue: OperationQueue {
    
    override init() {
        super.init()
        qualityOfService = .userInitiated
        maxConcurrentOperationCount = 1
    }
    
    override public func addOperation(_ operation: Operation) {
        let lastIndex = operations.count - 1
        
        if operations.count > 1 {
            for i in 0..<operations.count {
                if !operations[i].isCancelled && i != lastIndex {
                    operations[i].cancel()
                }
            }
        }
        super.addOperation(operation)
    }
}
