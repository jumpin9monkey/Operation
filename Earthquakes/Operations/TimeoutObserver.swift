/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

/**
    `TimeoutObserver` is a way to make an `OperationCustom` automatically time out and
    cancel after a specified time interval.
*/
struct TimeoutObserver: OperationObserver {
    // MARK: Properties

    static let timeoutKey = "Timeout"
    
    private let timeout: TimeInterval
    
    // MARK: Initialization
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(_ operation: OperationCustom) {
        // When the operation starts, queue up a block to cause it to time out.
        
        let when = DispatchTime.now() + timeout * Double(NSEC_PER_SEC)
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: when) {
            /*
             Cancel the operation if it hasn't finished and hasn't already
             been cancelled.
             */
            if !operation.isFinished && !operation.isCancelled {
                let error = OperationErrorCode.executionFailed(userInfo: [type(of: self).timeoutKey: String(self.timeout)])
                
                operation.cancelWithError(error)
            }
        }
    
    }

    func operation(_ operation: OperationCustom, didProduceOperation newOperation: Operation) {
        // No op.
    }

    func operationDidFinish(_ operation: OperationCustom, errors: [OperationErrorCode]) {
        // No op.
    }
}
