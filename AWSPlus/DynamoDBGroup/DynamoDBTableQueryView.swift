//
//  DynamoDBTableQueryView.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 22/12/2021.
//

import CoreData
import SwiftUI
import AWSDynamoDB
struct DynamoDBTableQueryView: View {
    @EnvironmentObject var account: AWSAccount
    @EnvironmentObject var dynamoDbService: DynamoDBService
    @State var tableDescriptionLoaded = false
    @State var queryResultsLoading = false
    @State var queryResultsLoaded = false
    @State var tableName: String
    @State var table : DynamoDBTable?
    @State var items = [DynamoDBItem]()
    @Binding var region: AWSRegionType
    
    @State private var primaryKey: String = ""
    @State private var primaryKeyType: Int = 0
    @State private var sortKey: String = ""
    @State private var sortKeyType: Int = 0
    @State private var error: String = "";
    
    var body: some View {
        VStack{
            if(!tableDescriptionLoaded){
                ProgressView()
            } else {
                
                Form {
                    Section(header: Text("Table Index")) {
                        //TextField("Alias (optional)", text: $alias)
                        Text("Not Supported")
                    }
                    Section(header: Text("Primary Key: \(String(describing: self.table!.primaryKey ?? ""))")) {
                        TextField("Alias (optional)", text: $primaryKey)
                        Picker("Type", selection: $primaryKeyType) {
                            Text("String").tag(0)
                            Text("Number").tag(1)
                            Text("Bool").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }
                    Section(header: Text("Sort Key: \(String(describing: self.table!.sortKey ?? ""))")) {
                        TextField("Alias (optional)", text: $sortKey)
                            .disabled(self.table!.sortKey?.isEmpty ?? true)
                        Picker("Type", selection: $sortKeyType) {
                            Text("String").tag(0)
                            Text("Number").tag(1)
                            Text("Bool").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .disabled(self.table!.sortKey?.isEmpty ?? true)
                    }
                    
                    Button("Run Query", action: {
                        if (self.primaryKey.isEmpty) {
                            error = "Fill the Primary Key first"
                            return
                        }
                        queryResultsLoading = true

                        let result = dynamoDbService.runDynamodbQuery(table: self.table!,
                                                                 region: region,
                                                                 primaryKey: self.primaryKey,
                                                                 primaryKeyType: self.primaryKeyType,
                                                                 sortKey: self.sortKey,
                                                                 sortKeyType: self.sortKeyType)
                        if(result.valid){
                            error = ""
                            items = result.items!
                        } else {
                            error = result.error!
                        }
                        queryResultsLoaded = true
                    })
                }
                Spacer()
                
                if(error != ""){
                    Text(error).foregroundColor(Color.red)
                }
            }
            
            if(queryResultsLoading) {
                Divider()
                List {
                    
                    if (tableDescriptionLoaded && queryResultsLoading && !queryResultsLoaded) {
                        ProgressView()
                    }
                    if(tableDescriptionLoaded && queryResultsLoaded){
                        if (items.count == 0) {
                            Text("No DynamoDB item found").padding()
                        } else {
                            Section(header: Text("Results")) {
                             
                                ForEach(items) { item in
                                    NavigationLink(destination: DynamoDBItemView(item: item)) {
                                        VStack(alignment: .leading) {
                                            Text(item.hashKey).font(.headline)
                                            Text(item.sortKey ?? "").font(.subheadline)
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }.onAppear() {
            if (items.count == 0) {
                table = dynamoDbService.describeTable(tableName: tableName, region: region)
                tableDescriptionLoaded = true
            }
        }
   
    }
}

struct DynamoDBTableQueryView_Previews: PreviewProvider {
    static var previews: some View {
        var items = [DynamoDBItem]()
        items.append(DynamoDBItem(hashKey: "hasKey", sortKey: "hasKey"))
        
        var table: DynamoDBTable = DynamoDBTable(tableName: "test", primaryKey: "pk", sortKey: "sk", count: 1, attributes: [])
        
        return DynamoDBTableQueryView(tableName: "test", table:table, items: items, region: .constant(.USEast1))
            .environmentObject(DynamoDBService(mock: true))
            .environmentObject(AWSAccount(context: PersistenceController.preview.container.viewContext))
    }
}
