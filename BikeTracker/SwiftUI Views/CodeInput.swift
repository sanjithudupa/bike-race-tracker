//
//  CodeInput.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 10/3/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI

//struct ContentView: View{
//    @State var codeString = ""
//    
//    var body: some View{
//        ZStack{
//            Color.green
//            
//            CodeInputs(codeString: $codeString)
//            
//            TextField("", text: $codeString)
//                .foregroundColor(.clear)
//                .accentColor(.clear)
//                .textContentType(.telephoneNumber)
//        }
//    }
//}

struct CodeInputs: View{
    @Binding var codeString:String
    @State var code:String = "    "
    @State var ok = false;
    
    @State var number1 = "3"
    @State var number2 = "2"
    @State var number3 = " "
    @State var number4 = " "
    
    @State var lastLength = 0
    
    var body: some View{
        return HStack{
            EmptyView()
            ForEach(codeArray(input: self.codeString, total: 4), id: \.self) {code in
                CodeInput(number: String(code))
            }.onAppear(){
                
            }
        }
    }
    
//    func capFour(input:String) -> String {
//        let noSpace = String(self.codeString.filter { !" ".contains($0) })
//
//        let amountSpaces = 3 - noSpace.count
//        let withAdded =  String(repeating: "s", count: amountSpaces >= 0 ? amountSpaces : 0)
//
//        let adjusted = noSpace + withAdded
//        print(adjusted)
////
//        return "   "
////        }
//    }

    func codeArray(input:String, total:Int) -> [String.Element]{
        var codeNumbers:Array = Array(input)
        let count = codeNumbers.count
        
        if(count < total){
            let numLess = total - count
            for _ in 1...numLess{
                codeNumbers.append(" ")
            }
        }else if(count > total){
            codeNumbers = Array(codeNumbers[..<total])
        }else{
            var fullCode = ""
            
            for i in codeNumbers{
                fullCode = fullCode + String(i)
            }
        }
        
        return codeNumbers
    }
}

struct CodeInput: View{
    @State var number:String
    var body: some View{
        ZStack{
            Text(number == " " ? "   " : " " + number + " ")
                .font(.system(size: 30))
                .frame(width: 50, height: 60)
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(self.number == " " ? Color.gray : Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [self.number == " " ? 5 : 1000]))
                )
        }.animation(.spring())
    }
}
