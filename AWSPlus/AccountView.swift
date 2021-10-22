//
//  AccountView.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 24/10/2021.
//

import SwiftUI
import CoreData
import AWSCore

struct AccountView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var accountService: AccountService
    @EnvironmentObject var account: AWSAccount

    @State var connected: Bool = false;
    @State var region: AWSRegionType = AWSRegionType.USEast1;

    var body: some View {
        VStack {

            List {
                NavigationLink(destination: DynamoDBTableListView(region: $region).environmentObject(account)) {
                    Text("DynamoDB").padding()
                }

//                NavigationLink(destination: DynamoDBTableListView(region: $region).environmentObject(account)) {
//                    Text("(Other services will be supported later)").padding()
//                }.disabled(true)
            }.disabled(!connected)

            Spacer()
            Text("Only a few services are supported in the app for now").font(.footnote)

        }.onAppear() {
            if (!connected) {
                connected = accountService.login(accessKey: account.accessKey!, secretKey: account.secretKey!).valid

                if (account.defaultRegion != 0) {
                    region = AWSRegionType.init(rawValue: Int(account.defaultRegion)) ?? AWSRegionType.USEast1
                } else {
                    region = AWSRegionType.USEast1
                }
            }
        }.navigationBarItems(leading: AccountDisplay()).navigationBarTitle(Text("AWS Services"))
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.init(inMemory: true).container.viewContext
        let account = AWSAccount.init(context: context)
        account.accountId = "accId"
        account.accessKey = "123456"
        account.secretKey = "123456"
        account.name = "Account alias"

        return AccountView(region: .USEast1).environmentObject(account)
    }
}
