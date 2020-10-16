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
    
    var body: some View {
        VStack{
            Image(systemName: self.image)
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
                    Text(self.city.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .layoutPriority(100)
                
                Spacer()
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
                Trail(image: "flag", type: "Park", name: "Kensington Metropark", city: "Milford Charter Township")
                
                Trail(image: "flag", type: "Trail", name: "ITC Trail", city: "Novi")
                
                Trail(image: "flag", type: "Trail", name: "Mike Levine Lakelands Trail", city: "Livingston County")
                
                Trail(image: "flag", type: "Trail", name: "Macomb Orchard Trail", city: "Washington Township")
            }
        }
    }
}
