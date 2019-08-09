/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

/**
    The `BlockObserver` is a way to attach arbitrary blocks to significant events
    in an `OperationCustom`'s lifecycle.
*/
struct BlockObserver: OperationObserver {

    
    // MARK: Properties
    
    private let startHandler: ((OperationCustom) -> Void)?
    private let produceHandler: ((OperationCustom, Operation) -> Void)?
    private let finishHandler: ((OperationCustom, [OperationErrorCode]) -> Void)?
    
    init(startHandler: ((OperationCustom) -> Void)? = nil, produceHandler: ((OperationCustom, Operation) -> Void)? = nil, finishHandler: ((OperationCustom, [OperationErrorCode]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(_ operation: OperationCustom) {
        startHandler?(operation)
    }
    
    func operation(_ operation: OperationCustom, didProduceOperation newOperation: Operation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(_ operation: OperationCustom, errors: [OperationErrorCode]) {
        finishHandler?(operation, errors)
    }
}
