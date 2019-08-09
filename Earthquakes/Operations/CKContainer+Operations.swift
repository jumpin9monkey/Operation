/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A convenient extension to CloudKit.CKContainer.
*/

import CloudKit

extension CKContainer {
    /**
        Verify that the current user has certain permissions for the `CKContainer`,
        and potentially requesting the permission if necessary.
        
        - parameter permission: The permissions to be verified on the container.

        - parameter shouldRequest: If this value is `true` and the user does not
            have the passed `permission`, then the user will be prompted for it.

        - parameter completion: A closure that will be executed after verification
            completes. The `Error` passed in to the closure is the result of either
            retrieving the account status, or requesting permission, if either
            operation fails. If the verification was successful, this value will
        be `nil`.
    */
    func verifyPermission(permission: CKContainer_Application_Permissions, requestingIfNecessary shouldRequest: Bool = false, completion: @escaping (String?) -> Void) {
        verifyAccountStatus(self, permission: permission, shouldRequest: shouldRequest, completion: completion)
    }
}

/**
    Make these helper functions instead of helper methods, so we don't pollute
    `CKContainer`.
*/
private func verifyAccountStatus(_ container: CKContainer, permission: CKContainer_Application_Permissions, shouldRequest: Bool, completion: @escaping (String?) -> Void) {
    container.accountStatus { accountStatus, accountError in
        if accountStatus == .available {
            if permission != [] {
                verifyPermission(container: container, permission: permission, shouldRequest: shouldRequest, completion: completion)
            }
            else {
                completion(nil)
            }
        }
        else {
            let error = "accountError ?? Error(domain: CKErrorDomain, code: CKErrorCode.NotAuthenticated.rawValue, userInfo: nil)  Deng"
            completion(error)
        }
    }
}

private func verifyPermission(container: CKContainer, permission: CKContainer_Application_Permissions, shouldRequest: Bool, completion: @escaping (String?) -> Void) {
    container.status(forApplicationPermission: permission) { (permissionStatus, permissionError) in
   
        if permissionStatus == .granted {
            completion(nil)
        }
        else if permissionStatus == .initialState && shouldRequest {
            requestPermission(container, permission: permission, completion: completion)
        }
        else {
            let error = "permissionError ?? Error(domain: CKErrorDomain, code: CKErrorCode.PermissionFailure.rawValue, userInfo: nil)  Deng"
            completion(error)
        }
    }
}




private func requestPermission(_ container: CKContainer, permission: CKContainer_Application_Permissions, completion: @escaping (String?) -> Void) {
    DispatchQueue.main.async {
        container.requestApplicationPermission(permission) { requestStatus, requestError in
            if requestStatus == .granted {
                completion(nil)
            }
            else {
                let error = "requestError ?? Error(domain: CKErrorDomain, code: CKErrorCode.PermissionFailure.rawValue, userInfo: nil)  Deng"
                completion(error)
            }
        }
    }
}
