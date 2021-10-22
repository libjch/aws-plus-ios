//
//  DynamoDBItemView.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 22/10/2021.
//

import SwiftUI
import os.log

struct DynamoDBItemView: View {
    let logger = Logger(subsystem: "com.libjch.DynamoDBService", category: "main")
    
    @State var item: DynamoDBItem
    var body: some View {
        VStack {
            List {
                
                ForEach(self.item.attributes ?? []) { attribute in
                    VStack(alignment: .leading) {
                        Text(attribute.name).font(.headline)
                        Text(attribute.value ?? "").font(.subheadline)
                    }
                }
            }.navigationBarItems(leading:
                                    
                                    VStack(alignment: .leading) {
                Text(item.hashKey).font(.headline)
                Text(item.sortKey ?? "").font(.subheadline)
            })
        }
    }
}

struct DynamoDBItemView_Previews: PreviewProvider {
    static var previews: some View {
        DynamoDBItemView(item: DynamoDBItem(hashKey: "testHash", sortKey: "testSort"))
    }
}

//func prettyPrintValue(value: String?) -> String{
//    if (value != nil) {
//        let encoder = JSONEncoder()
//        do {
//            let json = try encoder.encode(value)
//            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//            let string = try String(decoding: jsonData, as: UTF8.self)
//            return string
//        } catch _ as NSError {
//            return value ?? ""
//        }
//    } else {
//        return value ?? ""
//    }
//}
