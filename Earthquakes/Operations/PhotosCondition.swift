/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)

import Photos

/// A condition for verifying access to the user's Photos library.
struct PhotosCondition: OperationCondition {
    
    static let name = "Photos"
    static let isMutuallyExclusive = false
    
    init() { }
    
    func dependencyForOperation(_ operation: OperationCustom) -> Operation? {
        return PhotosPermissionOperation()
    }
    
    func evaluateForOperation(_ operation: OperationCustom, completion: (OperationConditionResult) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                completion(.Satisfied)

            default:
                let error = OperationErrorCode.conditionFailed(userInfo: [
                    OperationConditionKey:type(of: self).name
                    ])

                completion(.Failed(error))
        }
    }
}

/**
    A private `OperationCustom` that will request access to the user's Photos, if it
    has not already been granted.
*/
private class PhotosPermissionOperation: OperationCustom {
    override init() {
        super.init()

        addCondition(AlertPresentation())
    }
    
    override func execute() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
                DispatchQueue.main.async {
                    PHPhotoLibrary.requestAuthorization { status in
                        self.finish()
                    }
                }
     
            default:
                finish()
        }
    }
    
}

#endif
