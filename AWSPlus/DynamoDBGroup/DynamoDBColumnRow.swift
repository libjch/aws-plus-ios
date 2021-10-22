//
//  DynamoDBColumnRow.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 25/10/2021.
//

import SwiftUI

struct DynamoDBColumnRow: View {
    @State var selectedColumn: DynamoDBSelectedColumn

    var body: some View {
        Button(action: {
            selectedColumn.favorite = !selectedColumn.favorite
        }) {
            HStack {
                Text(selectedColumn.columnName)
                Spacer()
                if selectedColumn.favorite {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                }
            }
        }
    }
}

struct DynamoDBColumnRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DynamoDBColumnRow(selectedColumn: DynamoDBSelectedColumn(columnName: "TestName", favorite: true, order: 1))
            DynamoDBColumnRow(selectedColumn: DynamoDBSelectedColumn(columnName: "TestName", favorite: false, order: 1))
        }.previewLayout(.fixed(width: 300, height: 70))
    }
}
