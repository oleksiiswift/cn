//
//  OperationPhotoProcessingQueuer.swift
//  ECleaner
//
//  Created by alekseii sorochan on 29.07.2021.
//

import Foundation

public class OperationPhotoProcessingQueuer {
    
    public static let shared = OperationPhotoProcessingQueuer(name: "photoProcessingQueue")
    
    public let operationQueue = OperationQueue()
    
    public var operations: [Operation] {
        return operationQueue.operations
    }
    
    public var operationCount: Int {
        return operationQueue.operationCount
    }
    
    public var qualityOfService: QualityOfService {
        get {
            return operationQueue.qualityOfService
        } set {
            operationQueue.qualityOfService = newValue
        }
    }
    
    public var isExecuting: Bool {
        return !operationQueue.isSuspended
    }
    
    public var maxConcurrentOperationCount: Int {
        get {
            return operationQueue.maxConcurrentOperationCount
        } set {
            operationQueue.maxConcurrentOperationCount = newValue
        }
    }
    
    public init(name: String, maxConcurrentOperationCount: Int = Int.max, qualityOfService: QualityOfService = .default) {
        
        self.operationQueue.name = name
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.qualityOfService = qualityOfService
    }
    
    public func pause() {
        
        operationQueue.isSuspended = true
        for operations in operationQueue.operations {
            if let concurrentOperation = operations as? ConcurrentProcessOperation {
                concurrentOperation.pause()
            }
        }
    }
    
    public func resume() {
        operationQueue.isSuspended = false
        
        for operations in operationQueue.operations {
            if let concurrentOperation = operations as? ConcurrentProcessOperation {
                concurrentOperation.resume()
            }
        }
    }
    
    public func cancelAll() {
        operationQueue.cancelAllOperations()
    }
    
    public func waitUntilAllOperationsAreFinished() {
        operationQueue.waitUntilAllOperationsAreFinished()
    }
}


public extension OperationPhotoProcessingQueuer {
    
    func addOperation(_ operation: @escaping () -> Void) {
        operationQueue.addOperation(operation)
    }
    
    func addOperation(_ operation: Operation) {
        operationQueue.addOperation(operation)
    }
    
    func addChainedOperations(_ operations: [Operation], completionHandler: (() -> Void)? = nil) {
        for (index, operation) in operations.enumerated() {
            if index > 0 {
                operation.addDependency(operations[index - 1])
            }
            addOperation(operation)
        }
        guard let handler = completionHandler else { return }
        addCompletionHandler(handler)
    }
    
    
    func addCompletionHandler(_ completionHandler: @escaping () -> Void) {
        let operation = BlockOperation(block: completionHandler)
        
        if let lastOperation = operations.last {
            operation.addDependency(lastOperation)
        }
        addOperation(operation)
    }
    
    func addChainedOperations(_ operations: Operation..., completionHandler: (() -> Void)? = nil) {
        addChainedOperations(operations, completionHandler: completionHandler)
    }
}

public extension OperationPhotoProcessingQueuer {
        
    typealias QList = [OperationState]
    
    func state() -> QList {
        return OperationPhotoProcessingQueuer.state(of: operationQueue)
    }
    
    static func state(of queue: OperationQueue) -> QList {
        var operations: QList = []
        
        for operation in queue.operations {
            if let concurrentOperation = operation as? ConcurrentProcessOperation,
               let operationName = concurrentOperation.name {
                operations.append(OperationState(name: operationName, progress: concurrentOperation.progress, dependencies: operation.dependencies.compactMap { $0.name }))
            }
        }
        return operations
    }
}

public class OperationState: Codable {
    
    public var name: String
    public var progress: Int
    public var dependencies: [String]
    
    public init(name: String, progress: Int, dependencies: [String]) {
        self.name = name
        self.progress = progress
        self.dependencies = dependencies
    }
}

extension OperationState: CustomStringConvertible {
    public var description: String {
        return """
        Operation Name: \(name)
        Operation Progress: \(progress)
        Operation Dependencies: \(dependencies)
        """
    }
}
