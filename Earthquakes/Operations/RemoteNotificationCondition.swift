/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)

import UIKit
    
private let RemoteNotificationQueue = OperationQueueCustom()


extension Notification.Name {
    static let remoteNotificationName = Notification.Name("RemoteNotificationPermissionNotification")
}





private enum RemoteRegistrationResult {
    case Token(NSData)
    case Error(Error)
}



/// A condition for verifying that the app has the ability to receive push notifications.
struct RemoteNotificationCondition: OperationCondition {

    static var name = "RemoteNotification"
    static var isMutuallyExclusive = false
    //  static let
    
    static func didReceiveNotificationToken(token: Data) {
        NotificationCenter.default.post(name:.remoteNotificationName, object: nil, userInfo: [
            "token": token
        ])
        
    }
    
    static func didFailToRegister(error: Error) {
        NotificationCenter.default.post(name:.remoteNotificationName, object: nil, userInfo: [
            "error": error
        ])
    }
    
    let application: UIApplication
    
    init(application: UIApplication) {
        self.application = application
    }
    
    func dependencyForOperation(_ operation: OperationCustom) -> Operation? {
        
        return RemoteNotificationPermissionOperation(application: application, handler: { _ in })
    }
    
    func evaluateForOperation(_ operation: OperationCustom, completion: @escaping (OperationConditionResult) -> Void) {
        /*
            Since evaluation requires executing an operation, use a private operation
            queue.
        */
        RemoteNotificationQueue.addOperation(RemoteNotificationPermissionOperation(application: application) { result in
            switch result {
                case .Token(_):
                    completion(OperationConditionResult.Satisfied)
                
                    
                 case .Error(_):
                //case .Error(let underlyingError):
                  /*  let error = OperationErrorCode.conditionFailed(userInfo: [
                        OperationConditionKey:type(of: self).name,
                        type(of: self).hostKey: self.host_De.absoluteString
                        ])

                        
                        Error(code: .ConditionFailed, userInfo: [
                        OperationConditionKey: type(of: self).name,
                        NSUnderlyingErrorKey: underlyingError
                    ])
                    */
                    let error = OperationErrorCode.conditionFailed(userInfo: [
                        OperationConditionKey:type(of: self).name,
                        "type(of: self).hostKey  deng": "self.host_De.absoluteString  Deng"
                        ])
                    
                    
                    completion(.Failed(error))
            }
        })
    }
}

/**
    A private `OperationCustom` to request a push notification token from the `UIApplication`.
    
    - note: This operation is used for *both* the generated dependency **and**
        condition evaluation, since there is no "easy" way to retrieve the push
        notification token other than to ask for it.

    - note: This operation requires you to call either `RemoteNotificationCondition.didReceiveNotificationToken(_:)` or
        `RemoteNotificationCondition.didFailToRegister(_:)` in the appropriate
        `UIApplicationDelegate` method, as shown in the `AppDelegate.swift` file.
*/
private class RemoteNotificationPermissionOperation: OperationCustom {
    let application: UIApplication
    private let handler: (RemoteRegistrationResult) -> Void
    
    public init(application: UIApplication, handler: @escaping (RemoteRegistrationResult) -> Void) {
        self.application = application
        self.handler = handler

        super.init()
        
        /*
            This operation cannot run at the same time as any other remote notification
            permission operation.
        */
        addCondition(MutuallyExclusive<RemoteNotificationPermissionOperation>())
    }
    
    override func execute() {
        DispatchQueue.main.async {
            let notificationCenter = NotificationCenter.default
            
            notificationCenter.addObserver(self, selector: #selector(RemoteNotificationPermissionOperation.didReceiveResponse(notification:)), name: .remoteNotificationName, object: nil)
            
            self.application.registerForRemoteNotifications()
        }
    }
    
    @objc func didReceiveResponse(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        let userInfo = notification.userInfo

        if let token = userInfo?["token"] as? NSData {
            handler(.Token(token))
        }
        else if let error = userInfo?["error"] as? Error {
            handler(.Error(error))
        }
        else {
            fatalError("Received a notification without a token and without an error.")
        }

        finish()
    }
}
    
#endif
