/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    An extension to NSLock to simplify executing critical code.
*/

import Foundation

extension NSLock {
    func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}



//  Just remove @noescape will fix the error. @noescape is default



// https://stackoverflow.com/questions/49639875/rxswift-tutorial-example-attribute-can-only-be-applied-to-types-not-declaratio
