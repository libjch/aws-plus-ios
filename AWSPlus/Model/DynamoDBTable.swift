//
//  DynamoDBTable.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 24/10/2021.
//

import Foundation
import AWSDynamoDB

public struct DynamoDBTable {
    var tableName: String
    var primaryKey: String?
    var sortKey: String?
    var count: Int64?
    var region: AWSRegionType = AWSRegionType.USEast1
    var attributes: [DynamoDBAttribute]?
}

public struct DynamoDBAttribute {
    var name: String
    var type: AWSDynamoDBScalarAttributeType
}
