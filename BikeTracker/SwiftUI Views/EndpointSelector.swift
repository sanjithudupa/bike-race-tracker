//
//  EndpointSelector.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 8/2/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

struct EndpointSelector: View{
    @State var distance = "Move pin to set"
    var body: some View{
        GeometryReader{geometry in
            ZStack{
                EndpointSelectionMap()
                    .edgesIgnoringSafeArea(.all)
                ZStack{
                    Color.white
                    VStack{
                        Text("Linear Distance:")
                        Text(self.$distance.wrappedValue)
                            .fontWeight(.bold)
                    }
                }
                .frame(width: geometry.size.width/2 + 20, height: 60)
                .cornerRadius(10)
                .shadow(radius:10.0)
                .offset(y: geometry.size.height/2 - 40)
                
            }
        }.onAppear(){
            SocketIOManager.getInstance.updateEndpointDistanceLabel = self.updateEndpointDistanceLabel
        }
    }
    
    func updateEndpointDistanceLabel(){
        let distanceInMeters = SocketIOManager.getInstance.endpointDistance
        var final = String(format: "%.f", distanceInMeters)
        
        if(distanceInMeters <= 1609){
            final += " meters"
        }else{
            final = String(format: "%.2f", distanceInMeters / 1609.34) + " miles"
        }
        
        self.distance = final
    }
}

struct EndpointSelectionMap: UIViewRepresentable{
        
    func makeCoordinator() -> EndpointSelectionMap.Coordinator {
        return EndpointSelectionMap.Coordinator(parent1: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        
        let defaultC = CLLocationCoordinate2D(latitude: 34.011286, longitude: -116.166868)
        let c =  LocationManager.getInstance.getLocation()?.coordinate ?? defaultC
        let s = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        map.setRegion(MKCoordinateRegion(center: c, span: s), animated: false)
        
        let endpoint = MKPointAnnotation()
        endpoint.coordinate = c
        endpoint.title = "Race Endpoint"
        endpoint.subtitle = "Approximately where the race will end"
        
        map.delegate = context.coordinator
        
        map.addAnnotation(endpoint)
        map.showsUserLocation = true
        
        return map
    }

    func updateUIView(_ view: MKMapView, context: Context) {
    }
    
    class Coordinator: NSObject, MKMapViewDelegate{
        var parent : EndpointSelectionMap
        
        init(parent1: EndpointSelectionMap){
            parent = parent1
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            let line: MKPolyline = overlay as! MKPolyline
            let renderer = MKPolylineRenderer(polyline: line)
            
            let pathColor = UIColor.green
            
            renderer.fillColor = pathColor.withAlphaComponent(0.5)
            renderer.strokeColor = pathColor.withAlphaComponent(0.8)
            renderer.lineWidth = 12
            
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if(annotation.title == "Race Endpoint"){
                let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "endpoint")

                pinAnnotationView.pinTintColor = .green
                pinAnnotationView.isDraggable = true
                pinAnnotationView.canShowCallout = true
                pinAnnotationView.animatesDrop = true

                return pinAnnotationView
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            
            //draw line
            let line = MKPolyline(coordinates: [LocationManager.getInstance.getLocation()!.coordinate, view.annotation!.coordinate], count: 2)
            
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlay(line)
            
            //distance label
            let pinLocation = CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
            
            SocketIOManager.getInstance.endpointDistance = LocationManager.getInstance.getLocation()!.distance(from: pinLocation)
            SocketIOManager.getInstance.updateEndpointDistanceLabel?()
            
            //set endpoint
            SocketIOManager.getInstance.endpoint = view.annotation!.coordinate
            
            if(SocketIOManager.getInstance.endpoint != nil){
                SocketIOManager.getInstance.endpointHasBeenSet?()
            }
        }
        
    }
}

struct EndpointSelectorAlert: View{
    var onOk: () -> Void = {}
    @Binding var trigger : Bool
    @State var notSet = true
    
    var body: some View{
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(self.trigger ? 0.5 : 0)
            ZStack {
                Color.white
                VStack {
                    Text("Set Race Endpoint")
                    Text("You may leave this blank. Click the pin for more details")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                    Spacer()
                    EndpointSelector()
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            self.trigger = false
                        SocketIOManager.getInstance.endpoint = nil
                            self.onOk()
                        }, label: {
                            Text("Don't Set")
                        })
                        Spacer()
                        Spacer()
                        Button(action: {
                            self.trigger = false
                            self.onOk()
                        }, label: {
                            Text("Set Endpoint")
                        })
                            .disabled(self.$notSet.wrappedValue)
                        Spacer()
                    }
                }.padding()
            }
            .frame(width: 350, height: 500)
            .cornerRadius(20).shadow(radius: 20)
            .offset(y: self.trigger ? 0 : UIScreen.main.bounds.height)
            .animation(.spring())
        }.onAppear(){
            SocketIOManager.getInstance.endpointHasBeenSet = self.endpointHasBeenSet
        }
    }
    
    func endpointHasBeenSet(){
        self.notSet = false
    }
}
