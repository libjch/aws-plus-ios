//
//  AccountDisplay.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 25/10/2021.
//

import SwiftUI

struct AccountDisplay: View {
    @EnvironmentObject var account: AWSAccount

    var body: some View {
        if (account != nil) {
            VStack(alignment: .leading) {
                Text((account.name ?? account.accountId ?? "")).font(.headline)
                Text((account.iamArn ?? account.userId ?? "").replacingOccurrences(of: "arn:aws:iam::", with: "")).font(.subheadline)
            }
        }
    }
}

struct AccountDisplay_Previews: PreviewProvider {

    static var previews: some View {
        let account = AWSAccount()
        account.accessKey = "4242"
        account.iamArn = "iam arn string"
        account.userId = "123456"
        account.name = "account alias"
        return AccountDisplay().environmentObject(account)
    }
}
