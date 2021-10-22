//
//  ContentView.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 22/10/2021.
//

import SwiftUI
import CoreData

struct AccountListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: AWSAccount.allAWSAccountsFetchRequest()) var accounts: FetchedResults<AWSAccount>
    
    @State private var newIdeaTitle = ""
    @State private var newIdeaDescription = ""
    @State private var noAccount = false

    
    var body: some View {
        NavigationView {
            VStack {
//                Spacer()
//                    .frame(width: 10.0, height: 200.0)
//                    .background(Color(.systemGroupedBackground))
                
                List {
                    ForEach(self.accounts) { account in
                        NavigationLink(destination: AccountView().environmentObject(account)) {
                            AccountDisplay().environmentObject(account)
                        }.padding()
                    }.onDelete { (indexSet) in
                        let accountToDelete = self.accounts[indexSet.first!]
                        self.managedObjectContext.delete(accountToDelete)
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print(error)
                        }
                    }
                }
                
                if (accounts.count == 0) {
                    Spacer()
                }
                
                NavigationLink(destination: AccountAddView(), isActive: $noAccount) {
                    Text("Add a new AWS Account")
                        .padding(10.0)
                        .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.blue, lineWidth: 2.0))
                }
                .padding()
                .onAppear(){
                    self.noAccount = accounts.count == 0
                }
                
            }
            .navigationTitle("Identities")
        }
    }
}

struct AccountListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.init(inMemory: true).container.viewContext
        
        var accounts = [AWSAccount]()
        
        let account = AWSAccount(context: context)
        account.userId = "fakeUserId"
        account.accountId = "fakeAccountId"
        accounts.append(account)
        
        return AccountListView().environment(\.managedObjectContext, context)
        
    }
}
