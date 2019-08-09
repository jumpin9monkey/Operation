/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file defines the error codes and convenience functions for interacting with OperationCustom-related errors.
*/

import Foundation

let OperationErrorDomain = "OperationErrors"


/*
enum OperationErrorCode: Error, Equatable {
    case conditionFailed(userInfo: [String: String])
    case executionFailed(userInfo: [String: String])
}
*/



enum OperationErrorCode: Error, Equatable {
    case conditionFailed(userInfo: [String: String])
    case executionFailed(userInfo: [String: String])
    case temp
    
    
    static func ==(lhs: OperationErrorCode, rhs: OperationErrorCode) -> Bool {
        switch (lhs, rhs) {
        case (.conditionFailed(let lError), .conditionFailed(let rError)) where lError == rError:
            return true
        case (.executionFailed(let lError), .executionFailed(let rError)) where lError == rError:
            return true
        default:
            return false
        }
        
    }
}

/*
extension Error {
    convenience init(code: OperationErrorCode, userInfo: [NSObject: AnyObject]? = nil) {
        self.init(domain: OperationErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}


// This makes it easy to compare an `Error.code` to an `OperationErrorCode`.
func ==(lhs: Int, rhs: OperationErrorCode) -> Bool {
    return lhs == rhs.rawValue
}

func ==(lhs: OperationErrorCode, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}

 
  */
