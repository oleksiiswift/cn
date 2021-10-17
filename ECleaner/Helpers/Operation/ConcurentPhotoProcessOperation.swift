//
//  ConcurrentPhotoProcessOperation.swift
//  ECleaner
//
//  Created by alekseii sorochan on 29.07.2021.
//

import Foundation

class ConcurrentPhotoProcessOperation: Operation {
    
    public var executionBlock: ((_ operation: ConcurrentPhotoProcessOperation) -> Void)?
    
    override open var isAsynchronous: Bool {
        return true
    }

    override open var isExecuting: Bool {
        return checkIsExecuting
    }
    
    override open var isFinished: Bool {
        return checkIsFinishing
    }
    
    open var progress: Int = 0 {
        didSet {
            progress = progress < 100 ? (progress > 0 ? progress : 0) : 100
        }
    }
    
    open private(set) var currentAttempt = 1
    private var shouldRetry = true
    open var manualRetry = false
    open var success = true
    open var maximumRetries = 3

    private var checkIsExecuting = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        } didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var checkIsFinishing = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        } didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    public init(operationName: String? = nil, executionBlock: ((_ operation: ConcurrentPhotoProcessOperation) -> Void)? = nil) {
        super.init()
        
        self.name = name
        self.executionBlock = executionBlock
    }
    
    override open func start() {
        
        checkIsExecuting = true
        execute()
    }
    
    open func execute() {
        if let executionBlock = executionBlock {
            while shouldRetry, !manualRetry {
                executionBlock(self)
                finish(success)
            }
            retry()
        }
    }
    
    open func retry() {
        if manualRetry, shouldRetry, let executionBlock = executionBlock {
            executionBlock(self)
            finish(success)
        }
    }
    
    open func finish(_ success: Bool = true) {
        if success || currentAttempt >= maximumRetries {
            checkIsExecuting = false
            checkIsFinishing = true
            shouldRetry = false
        } else {
            currentAttempt += 1
            shouldRetry = true
        }
    }
    
    open func pause() {}
    open func resume() {}
}

extension ConcurrentPhotoProcessOperation {
    
    func addToQueuer(_ queue: OperationPhotoProcessingQueuer) {
        queue.addOperation(self)
    }
    
    func addToSharedQueuer() {
        OperationPhotoProcessingQueuer.shared.addOperation(self)
    }
}
