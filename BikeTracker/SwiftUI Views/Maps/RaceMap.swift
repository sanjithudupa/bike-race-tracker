//
//  Map.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 7/29/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import SwiftUI
import MapKit

struct RaceMapView: UIViewRepresentable{
    
    func makeCoordinator() -> RaceMapView.Coordinator {
        return RaceMapView.Coordinator(parent1: self)
    }
    
    @Binding var points : [[CLLocationCoordinate2D]]

    func makeUIView(context: Context) -> MKMapView{
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.mapType = .mutedStandard
        
        LocationManager.getInstance.start()
        
        let coordinate = LocationManager.getInstance.getLocation()?.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate!, span: span)
        
        map.setRegion(region, animated: true)
        
        return map
    }
    
    func updateUIView(_ view: MKMapView, context: Context){
        
        guard (points.count > 0)  else { return }
        
        var userIndex = 0
        
        for (usr, _) in SocketIOManager.getInstance.positions {
            if(usr == SocketIOManager.getInstance.userId){
                break
            }else{
                userIndex += 1
            }
        }

        
        let coordinate = points[userIndex].last
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate!, span: span)
        
        view.setRegion(region, animated: true)
        

        //remove old lines
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }
        
        if !view.annotations.isEmpty { view.removeAnnotations(view.annotations) }
        
        //draw polylines
        var polyLine:MKPolyline
        var count = 0
        
        for point in self.points{
            polyLine = MKPolyline(coordinates: point, count: self.points[count].count);
            polyLine.title = String(count);
            view.addOverlay(polyLine);
            count += 1
                        
            //draw markers
            let landmark = MKPointAnnotation()

            landmark.title = String(count)
            landmark.coordinate = point.last!

            view.addAnnotation(landmark)
        }
        
        
//        for point in self.points{
//            polyLine = MKPolyline(coordinates: point, count: self.points[count].count);
//            polyLine.title = String(count);
//            view.addOverlay(polyLine);
//
//            count += 1
//
//            //draw markers
//            if(view.annotations.count < self.points.count){
//                var landmark = MKPointAnnotation()
//
//                landmark.title = String(count)
//                landmark.coordinate = point.last!
//
//                view.addAnnotation(landmark)
//            }else{
//                var landmark: MKPointAnnotation = view.annotations[count - 1] as! MKPointAnnotation
//                landmark.coordinate = point.last!
//            }
//
//        }
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate{
        var routes = [[CLLocationCoordinate2D]]()
        //try storing images to reduce load time and computation
        //    var markerImages = [UIImage]()
        
        
        var parent : RaceMapView
        
        init(parent1: RaceMapView){
            parent = parent1
        }
        
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            let route: MKPolyline = overlay as! MKPolyline
            let renderer = MKPolylineRenderer(polyline: route)
            var index : Int
            
            if let strIndex = overlay.title {
                index = Int(strIndex ?? "0") ?? 0
            }
            else{
               index = 0
            }
            
            let pathColor = UIColor.randomColorFromSeed(input: index)
            
            renderer.fillColor = pathColor.withAlphaComponent(0.5)
            renderer.strokeColor = pathColor.withAlphaComponent(0.8)
            renderer.lineWidth = 15
            
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            var index : Int
            
            if let strIndex = annotation.title {
                index = Int(strIndex ?? "0") ?? 0
            }
            else{
               index = 0
            }
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.title ?? "0")
            
            let mapMarker = MapMarkerUI(frame: CGRect(x: 0, y: 0, width: 60, height: 60), color: UIColor.randomColorFromSeed(input: index-1))
            
            let markerImage = mapMarker.asImage()
            
            annotationView.image = markerImage
            
            return annotationView
        }
    }
}

class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    init(title: String?,
     subtitle: String?,
     coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

struct RaceMap: View {
//    @Binding var showing : CurrentView
    
    @Binding var currentView : CurrentView
    
    @State var allPoints = [[CLLocationCoordinate2D]]()
    
    @State var addCount = 0
    
    @State var youNewHost = false
    @State var amHost = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    func resetToHome(){
        presentationMode.wrappedValue.dismiss()
        currentView = .home
    }
    
    func newHost(){
        self.youNewHost = true
        showHostText()
    }
    
    func showHostText(){
        self.amHost = SocketIOManager.getInstance.amHost
    }
    
    func addToMap(){
        var allNewPoints = [[CLLocationCoordinate2D]]()
        for (_, pos) in SocketIOManager.getInstance.positions {
            allNewPoints.append(pos)
        }
        
        self.allPoints = allNewPoints
        
        print(self.allPoints)
    }
    
    var body: some View {
        ZStack{
            RaceMapView(points: $allPoints)
            
            if(self.$amHost.wrappedValue){
                Text("You are the Host")
                    .offset(y: UIScreen.main.bounds.height/4 + 70)
            }
            
            AlertView(title: "Host Left", text: "You are now the Race Host", trigger: self.$youNewHost)
            
        }.onAppear{
            SocketIOManager.getInstance.resetToHome = self.resetToHome
            SocketIOManager.getInstance.newHost = self.newHost
            SocketIOManager.getInstance.updatePositionsLabel = self.addToMap
            
            self.showHostText()
        }
    }
}
