//
//  DynamoDBTableView.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 24/10/2021.
//

import CoreData
import SwiftUI
import AWSDynamoDB

struct DynamoDBTableView: View {
    @EnvironmentObject var account: AWSAccount
    @EnvironmentObject var dynamoDbService: DynamoDBService
    @State var loaded = false
    @State var tableName: String
    @State var items = [DynamoDBItem]()
    @Binding var region: AWSRegionType

    var body: some View {
        VStack {
            HStack {
                Text(tableName).font(Font.title).padding()
                Spacer()
            }
            
            List {
                
             
                Section(header: Text("Actions")) {
                    
                    NavigationLink(destination: DynamoDBTableQueryView(tableName:tableName, region:$region)){
                        VStack(alignment: .leading) {
                            Text("Query").font(.headline)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Scan").font(.headline)
                    }
                }
                
                Section(header: Text("Sample Items")) {
                    ForEach(items) { item in
                        NavigationLink(destination: DynamoDBItemView(item: item)) {
                            VStack(alignment: .leading) {
                                Text(item.hashKey).font(.headline)
                                Text(item.sortKey ?? "").font(.subheadline)
                            }
                        }
                    }
                }
                if (!loaded) {
                    ProgressView()
                } else if (items.count == 0) {
                    Text("No DynamoDB item found").padding()
                }
            }.onAppear() {
                if (items.count == 0) {
                    let result = dynamoDbService.listObjectsInTable(tableName: tableName, numberItems: 10, region: region)
                    if(result.valid){
                        items = result.items!
                    } else {
                      // TODO Dsplay Error
                    }
                    loaded = true
                }
            }.navigationBarItems(leading: AccountDisplay()).navigationBarTitleDisplayMode(.inline)
        }
    }
}


#if DEBUG
struct DynamoDBTableView_Previews: PreviewProvider {
    static var previews: some View {
        var items = [DynamoDBItem]()
        items.append(DynamoDBItem(hashKey: "hasKey", sortKey: "hasKey"))

        return DynamoDBTableView(tableName: "test", items: items, region: .constant(.USEast1))
            .environmentObject(DynamoDBService(mock: true))
            .environmentObject(AWSAccount(context: PersistenceController.preview.container.viewContext))
    }
}
#endif
