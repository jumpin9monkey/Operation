/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation

/**
    A condition that specifies that every dependency must have succeeded.
    If any dependency was cancelled, the target operation will be cancelled as
    well.
*/
struct NoCancelledDependencies: OperationCondition {
    static let name = "NoCancelledDependencies"
    static let cancelledDependenciesKey = "CancelledDependencies"
    static let isMutuallyExclusive = false
    
    init() {
        // No op.
    }
    
    func dependencyForOperation(_ operation: OperationCustom) -> Operation? {
        return nil
    }
    
    func evaluateForOperation(_ operation: OperationCustom, completion: (OperationConditionResult) -> Void) {
        // Verify that all of the dependencies executed.
        let cancelled: [Operation] = operation.dependencies.filter { $0.isCancelled }

        if !cancelled.isEmpty {
            // At least one dependency was cancelled; the condition was not satisfied.
            let error = OperationErrorCode.conditionFailed(userInfo: [
                OperationConditionKey:type(of: self).name,
                type(of: self).cancelledDependenciesKey: "cancelled Deng"
                ])
            
            completion(.Failed(error))
        }
        else {
            completion(.Satisfied)
        }
    }
}
