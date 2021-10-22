//
//  DynamoDBItemsResult.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 22/12/2021.
//

import Foundation

public struct DynamoDBItemsResult {
    var valid: Bool
    var error: String?
    var items: [DynamoDBItem]?
}

