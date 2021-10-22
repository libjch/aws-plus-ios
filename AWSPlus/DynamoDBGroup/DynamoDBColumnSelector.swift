//
//  DynamoDBColumnSelector.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 25/10/2021.
//

import SwiftUI
import AWSCore

struct DynamoDBColumnSelector: View {
    @EnvironmentObject var account: AWSAccount
    @EnvironmentObject var dynamoDbService: DynamoDBService

    var tableName: String
    var region: AWSRegionType

    @State var columns: [String: DynamoDBSelectedColumn] = [:]

    var body: some View {

        List {
            ForEach(columns.sorted(by: >), id: \.key) { keyy, value in
                DynamoDBColumnRow(selectedColumn: value).onChange(of: value, perform: { newvalue in
                    self.columns[keyy]?.favorite = newvalue.favorite
                })
            }
        }.onAppear() {
            var tableDescription = dynamoDbService.describeTable(tableName: tableName, region: region)

            var prefTable: DynamoDBPrefTable
            if (!account.tables!.contains(tableName)) {
                prefTable = DynamoDBPrefTable(context: account.managedObjectContext!)
                prefTable.name = tableName
                prefTable.attributes = NSSet()
                account.tables?.setValue(prefTable, forKey: tableName)

            } else {
                prefTable = account.tables!.value(forKey: tableName) as! DynamoDBPrefTable
            }

            for attr2 in prefTable.attributes! {
                let attr = attr2 as! DynamoDBPrefAttribute
                columns[attr.name!] = DynamoDBSelectedColumn(columnName: attr.name!, favorite: attr.display, order: 0)
            }

            for attr in tableDescription.attributes! {
                columns[attr.name] = DynamoDBSelectedColumn(columnName: attr.name, favorite: false, order: 0)
                //prefTable.attributes?.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
            }
            PersistenceController.shared.save()
        }

    }
}

struct DynamoDBColumnSelector_Previews: PreviewProvider {
    static var previews: some View {
        DynamoDBColumnSelector(tableName: "test", region: AWSRegionType.USEast1)
    }
}

struct DynamoDBSelectedColumn {
    var columnName: String
    var favorite = false
    var order: Int?
}

extension DynamoDBSelectedColumn: Identifiable, Comparable {
    static func <(lhs: DynamoDBSelectedColumn, rhs: DynamoDBSelectedColumn) -> Bool {
        lhs.columnName < rhs.columnName
    }

    var id: String {
        columnName
    }
}
