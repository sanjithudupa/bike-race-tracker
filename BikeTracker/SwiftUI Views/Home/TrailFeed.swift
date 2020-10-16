//
//  TrailFeed.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 10/15/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI

struct Trail: View{
    var image: String
    var type: String
    var name: String
    var city: String
    var locationURL: String
    
    var body: some View {
        VStack{
            Image(self.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            HStack{
                VStack(alignment: .leading) {
                    Text(self.type)
                        .font(.headline)
                        .foregroundColor(.green)
                    Text(self.name)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .onTapGesture {
                            UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/?q=" + self.locationURL)! as URL)
                        }
                    Text(self.city.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .layoutPriority(100)
                
                Spacer()
//                VStack{
//                    Spacer()
//                    Button(action: {
//                        UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/?q=" + self.locationURL)! as URL)
//                    }){
//                        Image(systemName: "mappin.and.ellipse")
//                            .resizable()
//                            .frame(width:25, height: 30)
//                            .foregroundColor(.green)
//                    }
//
//                }
            }.padding()
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.2), lineWidth: 1)
        )
        .padding([.top, .horizontal])
        .shadow(radius: 7)
    }
}

struct TrailsFeed: View{
    var body: some View{
        ScrollView(.vertical) {
            VStack(spacing: 10) {
                Text("Find Nearby Trails:")
                    .font(.system(size: 30, weight:
                        .black, design: .rounded))
                Trail(image: "Kensington", type: "Park", name: "Kensington Metropark", city: "Milford Charter Township", locationURL: "Kensington+Metropark")
                
                Trail(image: "ITC", type: "Trail", name: "ITC Corridor Trail", city: "Novi", locationURL: "ITC+Community+Sports+Park")
                
                Trail(image: "MikeLevine", type: "Trail", name: "Mike Levine Lakelands Trail", city: "Livingston County", locationURL: "Pinckney+MI")
                
                Trail(image: "MacombOrchardTrail", type: "Trail", name: "Macomb Orchard Trail", city: "Washington Township",locationURL: "65665+Powell+Rd+Washington+MI+48095")
                
                Spacer()
                Spacer()
            }
        }
    }
}
