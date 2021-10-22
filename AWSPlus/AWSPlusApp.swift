//
//  AWSPlusApp.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 22/10/2021.
//

import SwiftUI
import AWSDynamoDB

@main struct AWSPlusApp: App {
    @StateObject private var ddbService = DynamoDBService(mock:false)
    @StateObject private var accountService = AccountService()

    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase


    var body: some Scene {
        WindowGroup {
            AccountListView().environmentObject(ddbService).environmentObject(accountService).environment(\.managedObjectContext, persistenceController.container.viewContext)
        }.onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

