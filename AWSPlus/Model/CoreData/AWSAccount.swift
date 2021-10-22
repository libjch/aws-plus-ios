//
//  AWSAccount.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 24/10/2021.
//

import Foundation
import CoreData

extension AWSAccount {
    public var id: String {
        (accountId ?? "") + (accessKey ?? "")
    }

    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func allAWSAccountsFetchRequest() -> NSFetchRequest<AWSAccount> {
        let request: NSFetchRequest<AWSAccount> = AWSAccount.fetchRequest()

        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        return request
    }
}


