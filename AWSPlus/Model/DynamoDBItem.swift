//
//  DynemoDBItem.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 22/10/2021.
//

import Foundation

struct DynamoDBItem {
    var hashKey: String
    var sortKey: String?
    var attributes: [DynamoDBAttributeValue]?
}

extension DynamoDBItem: Identifiable {
    var id: String {
        hashKey + (sortKey ?? "")
    }
}

struct DynamoDBAttributeValue: Hashable, Codable {
    var name: String
    var value: String?
    var attribute: [DynamoDBAttributeValue]?
}

extension DynamoDBAttributeValue: Identifiable {
    var id: String {
        name
    }
}
