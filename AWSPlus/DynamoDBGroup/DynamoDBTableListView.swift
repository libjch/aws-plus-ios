//
//  DynamoDBView.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 24/10/2021.
//

import SwiftUI
import AWSCore

struct DynamoDBTableListView: View {
    @EnvironmentObject var dynamoDbService: DynamoDBService
    @EnvironmentObject var account: AWSAccount

    @State var loaded = false
    @State var tables: [DynamoDBTable] = [DynamoDBTable]()
    @Binding var region: AWSRegionType

    var body: some View {
        VStack {
            RegionPicker(region: $region).onChange(of: region, perform: { newRegion in
                self.tables = dynamoDbService.listAllTable(region: newRegion)
            })
            if (!loaded) {
                ProgressView()
            }

            if (loaded && self.tables.count == 0) {
                Text("No table found, maybe change the region?").padding()
            }
            
            List {
                ForEach(self.tables, id: \.tableName) { table in
                    NavigationLink(destination: DynamoDBTableView(tableName: table.tableName, region: $region).environmentObject(account)) {
                        VStack(alignment: .leading) {
                            Text(table.tableName).font(.headline)
                        }
                    }
                }
            }

        }.onAppear() {
            if (loaded == false) {
                DispatchQueue.global().async {
                    self.tables = dynamoDbService.listAllTable(region: region)
                    loaded = true
                }
            }
        }.navigationBarItems(leading: AccountDisplay()).navigationTitle("DynamoDB Tables")
    }
}

struct DynamoDBTableListView_Previews: PreviewProvider {
    static var previews: some View {
        var result = [DynamoDBTable]()
        result.append(DynamoDBTable(tableName: "test"))
        return DynamoDBTableListView(tables: result, region: .constant(AWSRegionType.USEast1))
            .environmentObject(DynamoDBService(mock: true))
    }
}
