//
//  AWSAccountService.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 24/10/2021.
//

import AWSCore
import Foundation
import AWSAuthCore
import CoreData
import SwiftUI
import os.log

public class AccountService: ObservableObject {
    let logger = Logger(subsystem: "com.libjch.AccountService", category: "main")

    static var credentials: AWSStaticCredentialsProvider = AWSStaticCredentialsProvider.init()

    public init() {

    }

    public func login(accessKey: String, secretKey: String) -> AuthenticationResult {

        AccountService.credentials = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: AccountService.credentials)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        let identifyRequest = AWSSTSGetCallerIdentityRequest()

        var authResult = AuthenticationResult(valid: false)

        AWSSTS.default().getCallerIdentity(identifyRequest!).continueOnSuccessWith(block: { (awsTask: AWSTask<AWSSTSGetCallerIdentityResponse>) -> Bool in
            let identityResult = awsTask.result
            print(authResult)

            if (awsTask.isCompleted && !awsTask.isCancelled && !awsTask.isFaulted && awsTask.result != nil) {
                authResult.accountId = identityResult?.account
                authResult.userId = identityResult?.userId
                authResult.iamArn = identityResult?.arn
                authResult.valid = true
                return true
            } else if (awsTask.result != nil) {
                authResult.valid = false
                authResult.error = identityResult.debugDescription
            } else {
                authResult.valid = false
                authResult.error = String(describing: awsTask.error)
            }
            return false
        }).continueWith(block: { (awsTask: AWSTask<AnyObject>) -> Any? in
            if (awsTask.error != nil) {
                self.logger.error("Error to login with account \(String(describing: awsTask.error))")
                authResult.error = awsTask.error?.localizedDescription
            }
            return false
        }).waitUntilFinished()

        return authResult
    }
}

public struct AuthenticationResult {
    var valid: Bool
    var accountId: String?
    var userId: String?
    var iamArn: String?
    var error: String?
}
