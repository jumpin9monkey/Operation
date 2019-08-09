/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file shows how to make an OperationCondition that composes another OperationCondition.
*/

import Foundation

/**
    A simple condition that negates the evaluation of another condition.
    This is useful (for example) if you want to only execute an operation if the
    network is NOT reachable.
*/
struct NegatedCondition<T: OperationCondition>: OperationCondition {
    static var name: String {
        return "Not<\(T.name)>"
    }
    
    static var negatedConditionKey: String {
        return "NegatedCondition"
    }
    
    static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    let condition: T

    init(condition: T) {
        self.condition = condition
    }
    
    func dependencyForOperation(_ operation: OperationCustom) -> Operation? {
        return condition.dependencyForOperation(operation)
    }
    
    func evaluateForOperation(_ operation: OperationCustom, completion: @escaping (OperationConditionResult) -> Void) {
        
        condition.evaluateForOperation(operation) { ( result: OperationConditionResult) in

            switch result{
            case .Satisfied:
                // If the composed condition succeeded, then this one failed.
                let error = OperationErrorCode.conditionFailed(userInfo:  [
                    OperationConditionKey: type(of: self).name,
                    type(of: self).negatedConditionKey:  type(of:self.condition).name
                    ])
                
                completion(.Failed(error))
            case .Failed(_):
                
                //  case .Failed(let operationErrorCode):
                
                
                // If the composed condition failed, then this one succeeded.
                completion(.Satisfied)
                
            }
        
        }
    }
}
