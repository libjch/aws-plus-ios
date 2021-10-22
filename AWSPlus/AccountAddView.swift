//
//  AccountAddView.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 24/10/2021.
//

import SwiftUI
import Combine

struct AccountAddView: View {
    @EnvironmentObject var accountService: AccountService
    @Environment(\.presentationMode) var presentationMode

    @State private var accessKey: String = ""
    @State private var secretKey: String = ""
    @State private var alias: String = ""
    @State private var error: String = ""

    init() {

    }

    init(accessKey: String, secretKey: String, error: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.error = error
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Account alias")) {
                    TextField("Alias (optional)", text: $alias)
                }

                Section(header: Text("Have an Existing IAM Role?")) {
                    TextField("AccessKey", text: $accessKey)
                    TextField("SecretKey", text: $secretKey)
                }

                Section(header: Text("Create IAM Role to access the account")) {
                    Link(destination: URL(string: "https://console.aws.amazon.com/iam/home?region=us-east-1#/users$new?step=final&accessKey&userNames=ios-aws-plus-readonly&permissionType=policies&policies=arn:aws:iam::aws:policy%2FReadOnlyAccess")!, label: {
                        Text("Link to create the IAM role in your AWS Account")
                    })

                    Text("Copy the accessKey and secretKey from the new Role created in the two field above").disabled(true)

                }

                Button("Validate and create", action: {
                    if (self.accessKey.isEmpty) {
                        error = "Fill the Access Key first"
                        return
                    }
                    if (self.secretKey.isEmpty) {
                        error = "Fill the Secret Key first"
                        return
                    }

                    let result = accountService.login(accessKey: self.accessKey, secretKey: self.secretKey)

                    if (result.valid) {
                        let newAccount = AWSAccount(context: PersistenceController.shared.container.viewContext)
                        newAccount.accessKey = self.accessKey
                        newAccount.secretKey = self.secretKey

                        newAccount.accountId = result.accountId
                        newAccount.userId = result.userId
                        newAccount.iamArn = result.iamArn
                        newAccount.name = alias
                        PersistenceController.shared.save()
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        error = result.error ?? "Error validating the account"
                    }
                })
            }

            Spacer()

            Text(error).foregroundColor(Color.red)
        }.navigationTitle("Create new profile")
    }
}

struct AccountAddView_Previews: PreviewProvider {
    static var previews: some View {
        AccountAddView(accessKey: "akey", secretKey: "skey", error: "Test error message")
    }
}
