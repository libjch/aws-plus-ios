//
//  DynamoDBService.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 22/10/2021.
//

import AWSDynamoDB
import AWSCore
import Foundation
import UIKit
import SwiftUI
import SwiftyJSON
import os.log

public class DynamoDBService: ObservableObject {
    let logger = Logger(subsystem: "com.libjch.DynamoDBService", category: "main")
    var mock = false
    
#if DEBUG
    var mockTables = [DynamoDBTable]()
    var mockObjects = [DynamoDBItem]()
    var mockTableDescription = DynamoDBTable(tableName:"test")
    var mockAttributes = [DynamoDBAttribute]()
#endif
    
    public init(mock: Bool) {
#if DEBUG
        self.mock = mock
        setupMocks()
#endif
    }
    
    private func getDynamoDB(region: AWSRegionType) -> AWSDynamoDB {
        
        let configuration = AWSServiceConfiguration(region: region, credentialsProvider: AccountService.credentials)
        AWSDynamoDB.register(with: configuration!, forKey: "\(region)DynamoDB")
        return AWSDynamoDB(forKey: "\(region)DynamoDB")
        
    }
    
    func listAllTable(region: AWSRegionType) -> [DynamoDBTable] {
#if DEBUG
        if mock {
            return mockTables
        }
#endif
        
        let dynamoDb = getDynamoDB(region: region)
        
        self.logger.info("List All Tables")
        var result = [DynamoDBTable]()
        
        //creates the var to use as a variable in the listtables method. AWSDynamoDBListTablesInput is the input to
        //listTables.
        let listTableInput = AWSDynamoDBListTablesInput()
        
        //we run this closure upon calling listTables.
        let res = dynamoDb.listTables(listTableInput!).continueOnSuccessWith(block: { (awsTask: AWSTask<AWSDynamoDBListTablesOutput>) -> Any? in
            let listTablesOutput = awsTask.result
            for tableName: String in (listTablesOutput?.tableNames!)! {
                self.logger.info("Found Table:\(tableName)")
                result.append(DynamoDBTable(tableName: tableName))
            }
            return nil
        }).continueWith(block: { (awsTask: AWSTask<AnyObject>) -> Any? in
            if (awsTask.error != nil) {
                self.logger.error("Error reading the list of table \(String(describing: awsTask.error))")
            }
            return nil
        }).waitUntilFinished()
        
        result.sort(by: { $0.tableName > $1.tableName })
        
        return result
    }
    
    func describeTable(tableName: String, region: AWSRegionType) -> DynamoDBTable {
#if DEBUG
        if mock {
            return mockTableDescription
        }
#endif
        var table = DynamoDBTable(tableName: tableName)
        table.tableName = tableName
        
        let dynamoDb = getDynamoDB(region: region)
        let describeTableInput = AWSDynamoDBDescribeTableInput()!
        describeTableInput.tableName = tableName
        
        table.attributes = [DynamoDBAttribute]()
        
        dynamoDb.describeTable(describeTableInput).continueOnSuccessWith(block: { (task: AWSTask<AWSDynamoDBDescribeTableOutput>) -> Any? in
            for keySchemaElement in (task.result!.table!.keySchema! as [AWSDynamoDBKeySchemaElement]) {
                if (keySchemaElement.keyType == AWSDynamoDBKeyType.hash) {
                    table.primaryKey = keySchemaElement.attributeName
                }
                if (keySchemaElement.keyType == AWSDynamoDBKeyType.range) {
                    table.sortKey = keySchemaElement.attributeName
                }
            }
            
            for attr in task.result!.table!.attributeDefinitions! {
                table.attributes?.append(DynamoDBAttribute(name: attr.attributeName!, type: attr.attributeType))
            }
            table.count = task.result!.table!.itemCount!.int64Value
            
            return nil
        }).continueWith(block: { (awsTask: AWSTask<AnyObject>) -> Any? in
            if (awsTask.error != nil) {
                self.logger.error("Error reading the description of table \(String(describing: awsTask.error))")
            }
            return nil;
        }).waitUntilFinished()
        
        self.logger.info("Describe Table Results: \(String(describing: table))")
        return table
    }
    
    func listObjectsInTable(tableName: String, numberItems: Int, region: AWSRegionType) -> DynamoDBItemsResult {
#if DEBUG
        if mock {
            return DynamoDBItemsResult(valid: true, error: "", items: mockObjects)
        }
#endif
        
        let dynamoDb = getDynamoDB(region: region)
        
        let tableDescription = self.describeTable(tableName: tableName, region: region)
        var input = AWSDynamoDBScanInput()!
        
        input.tableName = tableName
        input.limit = numberItems as NSNumber
        
        var dynamoItems = [DynamoDBItem]()
        var results = DynamoDBItemsResult(valid: false, error: "", items: [])
       
        
        dynamoDb.scan(input).continueOnSuccessWith(block: { (result: AWSTask<AWSDynamoDBScanOutput>) -> Any? in
            for item in result.result!.items! {
                // One dynamodb item
                
                self.logger.info("Item: \(item)")
                
                var dynamoItem = DynamoDBItem(hashKey: "")
                dynamoItem.attributes = [DynamoDBAttributeValue]()
                
                for (attrName, attrValue) in item {
                    var value = ""
                    if (attrValue.s != nil) {
                        value = attrValue.s!
                    } else if (attrValue.n != nil) {
                        value = attrValue.n!
                    } else if (attrValue.b != nil) {
                        value = String(decoding: attrValue.b!, as: UTF8.self)
                    } else if (attrValue.ss != nil) {
                        value = "type unsupported"
                    }
                    if (attrName == tableDescription.primaryKey) {
                        dynamoItem.hashKey = value
                    }
                    if (attrName == tableDescription.sortKey) {
                        dynamoItem.sortKey = value
                    }
                    
                    let attribute = DynamoDBAttributeValue(name: attrName, value: value)
                    dynamoItem.attributes!.append(attribute)
                }
                
                dynamoItems.append(dynamoItem)
                
            }
            dynamoItems = dynamoItems.sorted(by: { ($0.hashKey + ($0.sortKey ?? "")) < ($1.hashKey + ($1.sortKey ?? "")) })
            results = DynamoDBItemsResult(valid: true, error: "", items: dynamoItems)
            return nil
        }).continueWith(block: { (awsTask: AWSTask<AnyObject>) -> Any? in
            if (awsTask.error != nil) {
                results = DynamoDBItemsResult(valid: false, error: awsTask.error?.localizedDescription, items: [])
                self.logger.error("Error scanning items: \(String(describing: awsTask.error))")
            }
            return nil
        }).waitUntilFinished()
        
        
        return results
        
    }
    
    fileprivate func addKeyCondition(_ keyType: Int, _ keyValue: String, _ keyName: String, _ keyConditionExpression: inout String, _ expressionAttributeNames: inout [String : String], _ expressionAttributeValues: inout [String : AWSDynamoDBAttributeValue]) {
        let pkValue: AWSDynamoDBAttributeValue = AWSDynamoDBAttributeValue()
        switch keyType {
        case 0:
            pkValue.s = keyValue
        case 1:
            pkValue.n = keyValue
        default:
            pkValue.s = keyValue
        }
        if(keyConditionExpression.count > 1){
            keyConditionExpression += " AND "
        }
        keyConditionExpression += "#\(keyName) = :\(keyName)"
        expressionAttributeNames.updateValue(keyName, forKey: "#\(keyName)")
        expressionAttributeValues.updateValue(pkValue, forKey:":\(keyName)")
    }
    
    func runDynamodbQuery(table: DynamoDBTable,
                          region: AWSRegionType,
                          primaryKey: String,
                          primaryKeyType: Int,
                          sortKey: String?,
                          sortKeyType: Int?) -> DynamoDBItemsResult {
#if DEBUG
        if mock {
            return DynamoDBItemsResult(valid: true, error: "", items: mockObjects)
        }
#endif
        self.logger.info("Calling Query \(table.tableName) on region \(String(describing: region)) with \(table.primaryKey!) =  \(primaryKey) of type: \(primaryKeyType)")
        let dynamoDb = getDynamoDB(region: region)
        
        let input = AWSDynamoDBQueryInput()!
        input.tableName = table.tableName
        
        var expressionAttributeNames = [String: String]()
        var expressionAttributeValues = [String: AWSDynamoDBAttributeValue]()
        var keyConditionExpression = "";
        
        addKeyCondition(primaryKeyType, primaryKey, table.primaryKey!, &keyConditionExpression, &expressionAttributeNames, &expressionAttributeValues)
        
        if(sortKey != nil && sortKeyType != nil && sortKey!.count > 0){
            addKeyCondition(sortKeyType!, sortKey!, table.sortKey!, &keyConditionExpression, &expressionAttributeNames, &expressionAttributeValues)
        }
        input.keyConditionExpression = keyConditionExpression
        input.expressionAttributeNames = expressionAttributeNames
        input.expressionAttributeValues = expressionAttributeValues
        
        var dynamoItems = [DynamoDBItem]()
        var results = DynamoDBItemsResult(valid: false, error: "", items: [])
       
    
        dynamoDb.query(input).continueOnSuccessWith(block: { (result: AWSTask<AWSDynamoDBQueryOutput>) -> Any? in
            for item in result.result!.items! {
                // One dynamodb item
                
                self.logger.info("Item: \(item)")
                
                var dynamoItem = DynamoDBItem(hashKey: "")
                dynamoItem.attributes = [DynamoDBAttributeValue]()
                
                for (attrName, attrValue) in item {
                    var value = ""
                    if (attrValue.s != nil) {
                        value = attrValue.s!
                    } else if (attrValue.n != nil) {
                        value = attrValue.n!
                    } else if (attrValue.b != nil) {
                        value = String(decoding: attrValue.b!, as: UTF8.self)
                    } else if (attrValue.ss != nil) {
                        value = "type unsupported"
                    }
                    if (attrName == table.primaryKey) {
                        dynamoItem.hashKey = value
                    }
                    if (attrName == table.sortKey) {
                        dynamoItem.sortKey = value
                    }
                    let attribute = DynamoDBAttributeValue(name: attrName, value: value)
                    dynamoItem.attributes!.append(attribute)
                }
                dynamoItems.append(dynamoItem)
            }
            dynamoItems = dynamoItems.sorted(by: { ($0.hashKey + ($0.sortKey ?? "")) < ($1.hashKey + ($1.sortKey ?? "")) })
            results = DynamoDBItemsResult(valid: true, error: "", items: dynamoItems)
            return nil
        }).continueWith(block: { (awsTask: AWSTask<AnyObject>) -> Any? in
            if (awsTask.error != nil) {
                results = DynamoDBItemsResult(valid: false, error: String(describing: awsTask.error), items: [])
                self.logger.error("Error scanning items: \(String(describing: awsTask.error))")
            }
            return nil
        }).waitUntilFinished()
        
        return results
    }
    
}

#if DEBUG
extension DynamoDBService{
    
    private func setupMocks(){
        for i in 0...10 {
            let table = DynamoDBTable(tableName:"mock-table-\(i)")
            mockTables.append(table)
        }
        for i in 0...10 {
            let object = DynamoDBItem(hashKey: "hashKey\(i)", sortKey: i % 2 == 0 ? "sortKey" : "")
            mockObjects.append(object)
        }
        mockTableDescription = mockTables[0]
        mockTableDescription.primaryKey = "primaryKey"
        mockTableDescription.sortKey = "sortKey"
        mockTableDescription.count = 4
        mockTableDescription.attributes = mockAttributes
    }
}
#endif
