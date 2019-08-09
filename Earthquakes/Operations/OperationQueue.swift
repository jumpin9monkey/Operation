/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains an OperationQueue subclass.
*/

import Foundation

/**
    The delegate of an `OperationQueueCustom` can respond to `OperationCustom` lifecycle
    events by implementing these methods.

    In general, implementing `OperationQueueDelegate` is not necessary; you would
    want to use an `OperationObserver` instead. However, there are a couple of
    situations where using `OperationQueueDelegate` can lead to simpler code.
    For example, `GroupOperation` is the delegate of its own internal
    `OperationQueueCustom` and uses it to manage dependencies.
*/

protocol OperationQueueDelegate: NSObjectProtocol {
    func operationQueue(_ operationQueue: OperationQueueCustom, willAddOperation operation: Operation)
    func operationQueue(_ operationQueue: OperationQueueCustom, operationDidFinish operation: Operation, withErrors errors: [OperationErrorCode])
}

/**
    `OperationQueueCustom` is an `OperationQueue` subclass that implements a large
    number of "extra features" related to the `OperationCustom` class:
    
    - Notifying a delegate of all operation completion
    - Extracting generated dependencies from operation conditions
    - Setting up dependencies to enforce mutual exclusivity
*/


class OperationQueueCustom: OperationQueue {
    
    
    
    weak var delegate: OperationQueueDelegate?
    
    override func addOperation(_ op: Operation){
        
        if let opCustom = op as? OperationCustom {
            // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
            let delegate = BlockObserver(
                startHandler: nil,
                produceHandler: { [weak self] in
                    self?.addOperation($1)
                },
                finishHandler: { [weak self] in
                    if let q = self {
                        q.delegate?.operationQueue(q, operationDidFinish: $0, withErrors: $1)
                    }
                }
            )
            opCustom.addObserver(delegate)
            
            // Extract any dependencies needed by this operation.
            let dependencies = opCustom.conditions.compactMap {
                $0.dependencyForOperation(opCustom)
            }
                
            for dependency in dependencies {
                opCustom.addDependency(dependency)

                self.addOperation(dependency)
            }
            
            /*
                With condition dependencies added, we can now see if this needs
                dependencies to enforce mutual exclusivity.
            */
            
            
            let concurrencyCategories: [String] = opCustom.conditions.compactMap { condition in
                if !type(of: condition).isMutuallyExclusive { return nil }
                
                return "\(type(of: condition))"
            }

            if !concurrencyCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.sharedExclusivityController

                exclusivityController.addOperation(operation: opCustom, categories: concurrencyCategories)
                
                opCustom.addObserver(BlockObserver { operation, _ in
                    exclusivityController.removeOperation(operation: operation, categories: concurrencyCategories)
                })
            }
            
            /*
                Indicate to the operation that we've finished our extra work on it
                and it's now it a state where it can proceed with evaluating conditions,
                if appropriate.
            */
            opCustom.willEnqueue()
        }// if let op = operation as? OperationCustom {
        else {
            /*
                For regular `Operation`s, we'll manually call out to the queue's
                delegate we don't want to just capture "operation" because that
                would lead to the operation strongly referencing itself and that's
                the pure definition of a memory leak.
            */
            op.addCompletionBlock { [weak self, weak op] in
                guard let queue = self, let operation = op else { return }
                queue.delegate?.operationQueue(queue, operationDidFinish: operation, withErrors: [])
            }
        }
        
        delegate?.operationQueue(self, willAddOperation: op)
        super.addOperation(op)
        
    }
    
    
    
    
    override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool){
    
        /*
            The base implementation of this method does not call `addOperation()`,
            so we'll call it ourselves.
        */
        for operation in ops {
            addOperation(operation)
        }
        
        if wait {
            for operation in ops {
              operation.waitUntilFinished()
            }
        }
    }
}
