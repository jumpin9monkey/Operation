/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)
    
import PassKit

/// A condition for verifying that Passbook exists and is accessible.
struct PassbookCondition: OperationCondition {
    
    static let name = "Passbook"
    static let isMutuallyExclusive = false
    
    init() { }
    
    func dependencyForOperation(_ operation: OperationCustom) -> Operation? {
        /*
            There's nothing you can do to make Passbook available if it's not
            on your device.
        */
        return nil
    }
    
    func evaluateForOperation(_ operation: OperationCustom, completion: (OperationConditionResult) -> Void) {
        if PKPassLibrary.isPassLibraryAvailable() {
            completion(.Satisfied)
        }
        else {
            let error = OperationErrorCode.conditionFailed(userInfo: [ OperationConditionKey:type(of: self).name])
            completion(.Failed(error))
        }
    }
}
    
#endif
