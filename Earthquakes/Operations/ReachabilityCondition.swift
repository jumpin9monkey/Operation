/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation
import SystemConfiguration

/**
    This is a condition that performs a very high-level reachability check.
    It does *not* perform a long-running reachability check, nor does it respond to changes in reachability.
    Reachability is evaluated once when the operation to which this is attached is asked about its readiness.
*/
struct ReachabilityCondition: OperationCondition {
    static let hostKey = "Host"
    static var name = "Reachability"
    static var isMutuallyExclusive = false
    
    let host_De: URL
    
    
    init(host: URL) {
        self.host_De = host
    }
    
    func dependencyForOperation(_ operation: OperationCustom) -> Operation? {
        return nil
    }
    
    func evaluateForOperation(_ operation: OperationCustom, completion: @escaping (OperationConditionResult) -> Void) {
        ReachabilityController.requestReachability(url: host_De) { reachable in
            if reachable {
                completion(OperationConditionResult.Satisfied)
            }
            else {
                let error = OperationErrorCode.conditionFailed(userInfo: [
                    OperationConditionKey:type(of: self).name,
                    type(of: self).hostKey: self.host_De.absoluteString
                    ])

                completion(.Failed(error))
            }
        }
    }
    
}

/// A private singleton that maintains a basic cache of `SCNetworkReachability` objects.
private class ReachabilityController {
    static var reachabilityRefs = [String: SCNetworkReachability]()

    static let reachabilityQueue = DispatchQueue(label: "Operations.Reachability")
        
    
    static func requestReachability(url: URL, completionHandler: @escaping (Bool) -> Void) {
        if let host = url.host {
            
            reachabilityQueue.async {
                
                var ref = self.reachabilityRefs[host]

                if ref == nil {

                    ref = SCNetworkReachabilityCreateWithName(nil, String(describing: host.cString(using: String.Encoding.utf8)))
                }
                
                if let ref = ref {
                    self.reachabilityRefs[host] = ref
                    
                    var reachable = false
                    var flags: SCNetworkReachabilityFlags = []
                    if SCNetworkReachabilityGetFlags(ref, &flags) != false {
                        /*
                            Note that this is a very basic "is reachable" check.
                            Your app may choose to allow for other considerations,
                            such as whether or not the connection would require
                            VPN, a cellular connection, etc.
                        */
                        reachable = flags.contains(.reachable)
                    }
                    completionHandler(reachable)
                }
                else {
                    completionHandler(false)
                }
            }
        }
        else {
            completionHandler(false)
        }
    }
}
