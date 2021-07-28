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
        qualityOfService = .background

        maxConcurrentOperationCount = 10
    }

    override public func addOperation(_ operation: Operation) {
        let lastIndex = operations.count

        if operations.count > 1 {
            for i in 0..<operations.count {
                if !operations[i].isCancelled && i != lastIndex - 1  {
                    operations[i].cancel()
                }
            }
        }
        super.addOperation(operation)
    }

    func cancelAll() {
        self.cancelAllOperations()
    }

    func cancelOperations(in operationQueue: OperationQueue) {
        print("Cancelling all operations.")
        operationQueue.cancelAllOperations()
    }
}

class FetchingOperationQueue {
    
//        let operationQueue = AssetsOperationQueue()
    
    let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .background
        operationQueue.underlyingQueue = DispatchQueue(label: "com.test.concurrency")
        return operationQueue
    }()
    
    private var photoManager = PhotoManager()

    func start() {
        
        let operationBlock1 = BlockOperation()
        operationBlock1.addExecutionBlock { [unowned operationBlock1] in
            guard !operationBlock1.isCancelled else {
                print("Operation 1: Cancelled")
                return
            }
            self.photoManager.calculateAssetsDiskSpace()
        }
        
        let operationBlock2 = BlockOperation()
        operationBlock2.addExecutionBlock { [unowned operationBlock2] in
            guard !operationBlock2.isCancelled else {
                print("Operation 2: Cancelled")
                return
            }
            self.photoManager.calculateLargeVideosCount()
        }
        
        let operationBlock3 = BlockOperation()
        operationBlock3.addExecutionBlock { [unowned operationBlock3] in
            guard !operationBlock3.isCancelled else {
                print("Operation 3: Cancelled")
                return
            }
            self.photoManager.calculateRecentlyDeleted()
        }
        
        let operationBlock4 = BlockOperation()
        operationBlock4.addExecutionBlock { [unowned operationBlock4] in
            guard !operationBlock4.isCancelled else {
                print("Operation 4: Cancelled")
                return
            }
            self.photoManager.calculateAssetsDiskSpace()
        }
        
        let operationBlock5 = BlockOperation()
        operationBlock5.addExecutionBlock { [unowned operationBlock5] in
            guard !operationBlock5.isCancelled else {
                print("Operation 5: Cancelled")
                return
            }
            self.photoManager.calculateVideoCount()
        }
        
        let operationBlock6 = BlockOperation()
        operationBlock6.addExecutionBlock { [unowned operationBlock6] in
            guard !operationBlock6.isCancelled else {
                print("Operation 6: Cancelled")
                return
            }
            self.photoManager.calculatePhotoCount()
        }
        
        let operationBlock7 = BlockOperation()
        operationBlock7.addExecutionBlock { [unowned operationBlock7] in
            guard !operationBlock7.isCancelled else {
                print("Operation 7: Cancelled")
                return
            }
            self.photoManager.calculateScreenRecordsCout()
        }
        
        let operationBlock8 = BlockOperation()
        operationBlock8.addExecutionBlock { [unowned operationBlock8] in
            guard !operationBlock8.isCancelled else {
                print("Operation 8: Cancelled")
                return
            }
            self.photoManager.calculateScreenShotsCount()
        }
        
        let operationBlock9 = BlockOperation()
        operationBlock9.addExecutionBlock { [unowned operationBlock9] in
            guard !operationBlock9.isCancelled else {
                print("Operation 9: Cancelled")
                return
            }
            self.photoManager.calculateLivePhotoCount()
        }
        
        let operationBlock10 = BlockOperation()
        operationBlock10.addExecutionBlock { [unowned operationBlock10] in
            guard !operationBlock10.isCancelled else {
                print("Operation 10: Cancelled")
                return
            }
            self.photoManager.calculateSelfiesCount()
        }
        
        operationQueue.addOperation(operationBlock1)
        operationQueue.addOperation(operationBlock2)
        operationQueue.addOperation(operationBlock4)
        operationQueue.addOperation(operationBlock5)
        operationQueue.addOperation(operationBlock6)
        operationQueue.addOperation(operationBlock7)
        operationQueue.addOperation(operationBlock8)
        operationQueue.addOperation(operationBlock9)
        operationQueue.addOperation(operationBlock9)
    }

    func exitAndCancelOperations() {
        exitAndCancelOperations(in: operationQueue)
        debugPrint("done")
    }
    
    func exitAndCancelOperations(in operationQueue: OperationQueue) {
        print("Cancelling all operations.")
        operationQueue.cancelAllOperations()
    }
}
