/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Contains the code to manage the visibility of the network activity indicator
*/

import UIKit

/**
    An `OperationObserver` that will cause the network activity indicator to appear
    as long as the `OperationCustom` to which it is attached is executing.
*/
struct NetworkObserver: OperationObserver {
    // MARK: Initilization

    init() { }
    
    func operationDidStart(_ operation: OperationCustom) {
        DispatchQueue.main.async {
            // Increment the network indicator's "reference count"
            NetworkIndicatorController.sharedIndicatorController.networkActivityDidStart()
        }
    }
    
    func operation(_ operation: OperationCustom, didProduceOperation newOperation: Operation) { }
    
    func operationDidFinish(_ operation: OperationCustom, errors: [OperationErrorCode]) {
        DispatchQueue.main.async {
            // Decrement the network indicator's "reference count".
            NetworkIndicatorController.sharedIndicatorController.networkActivityDidEnd()
        }
    }
    
}

/// A singleton to manage a visual "reference count" on the network activity indicator.
private class NetworkIndicatorController {
    // MARK: Properties

    static let sharedIndicatorController = NetworkIndicatorController()

    private var activityCount = 0
    
    private var visibilityTimer: TimerDeng?
    
    // MARK: Methods
    
    func networkActivityDidStart() {
        assert(Thread.isMainThread, "Altering network activity indicator state can only be done on the main thread.")

        activityCount += 1
        
        updateIndicatorVisibility()
    }
    
    func networkActivityDidEnd() {
        assert(Thread.isMainThread, "Altering network activity indicator state can only be done on the main thread.")
        
        activityCount -= 1
        
        updateIndicatorVisibility()
    }
    
    private func updateIndicatorVisibility() {
        if activityCount > 0 {
            showIndicator()
        }
        else {
            /*
                To prevent the indicator from flickering on and off, we delay the
                hiding of the indicator by one second. This provides the chance
                to come in and invalidate the timer before it fires.
            */
            visibilityTimer = TimerDeng(interval: 1.0) {
                self.hideIndicator()
            }
        }
    }
    
    private func showIndicator() {
        visibilityTimer?.cancel()
        visibilityTimer = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideIndicator() {
        visibilityTimer?.cancel()
        visibilityTimer = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}





/// Essentially a cancellable `dispatch_after`.
class TimerDeng {
    // MARK: Properties
    
    private var isCancelled = false
    
    // MARK: Initialization

    init(interval: TimeInterval, handler: @escaping ()->Void) {
        
        let when = DispatchTime.now() + interval * Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.isCancelled == false {
                handler()
            }
        }
    }
    
    func cancel() {
        isCancelled = true
    }
}
