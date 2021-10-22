//
//  RegionPicker.swift
//  AWSPlus
//
//  Created by Jean-Christophe Libbrecht on 25/10/2021.
//

import SwiftUI
import AWSCore

struct RegionPicker: View {
    @Binding var region: AWSRegionType
    @EnvironmentObject var account: AWSAccount

    var body: some View {
        HStack(spacing: 0.0) {
            Text("Region").font(.headline).padding(.trailing, 5.0)

            Picker(selection: $region, label: Text("Picker")) {
                Group {
                    Text("us-east-1").tag(AWSRegionType.USEast1)
                    Text("us-east-2").tag(AWSRegionType.USEast2)
                    Text("us-west-1").tag(AWSRegionType.USWest1)
                    Text("us-west-2").tag(AWSRegionType.USWest2)
                }
                VStack {Divider()}
                Group {
                    Text("eu-west-1").tag(AWSRegionType.EUWest1)
                    Text("eu-west-2").tag(AWSRegionType.EUWest2)
                    Text("eu-west-3").tag(AWSRegionType.EUWest3)
                    Text("eu-central-1").tag(AWSRegionType.EUCentral1)
                }
                VStack {Divider()}
                Group {
                    Text("ap-northeast-1").tag(AWSRegionType.APNortheast1)
                    Text("ap-northeast-2").tag(AWSRegionType.APNortheast2)
                    Text("ap-southeast-1").tag(AWSRegionType.APSoutheast1)
                    Text("ap-southeast-2").tag(AWSRegionType.APSoutheast2)
                    Text("ap-south-1").tag(AWSRegionType.APSouth1)
                }
                VStack {Divider().padding(.leading)}
                Group {
                    Text("sa-east-1 ").tag(AWSRegionType.SAEast1)
                }
            }.onChange(of: region) { tag in
                print("Change region \(tag)")
                account.defaultRegion = Int16(region.rawValue)
            }
            .padding(5.0)
            .overlay(RoundedRectangle(cornerRadius: 5.0).stroke(Color.blue, lineWidth: 2.0))
            //.padding().border(Color.blue)
            
        }.frame(maxWidth: .infinity)
 
    }
}

struct RegionPicker_Previews: PreviewProvider {
    static var previews: some View {
        RegionPicker(region: .constant(.USEast1))
    }
}
