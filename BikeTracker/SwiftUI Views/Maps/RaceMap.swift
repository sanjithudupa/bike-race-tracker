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
    
    @Binding var points: [[CLLocationCoordinate2D]]
    
    @Binding var map: MKMapView
    @State var alignView: (() -> Void)?
    
    @State var lastCoordinate:CLLocationCoordinate2D?


    func makeUIView(context: Context) -> MKMapView{
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
        
        var ct = 0
        var offlineUsers = [Int]()
        for (usr, _) in SocketIOManager.getInstance.positions {
            if(!SocketIOManager.getInstance.users.contains(usr)){
                offlineUsers.append(ct)
            }
            
            ct += 1
        }
        
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
                        
            //draw markers
            let landmark = MKPointAnnotation()

            landmark.title = String(count)
            
            count += 1
            
//            if(offlineUsers.contains(count)){
//                landmark.subtitle = "offline"
//            }
            
            landmark.coordinate = point.last!

            view.addAnnotation(landmark)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate/*, UIGestureRecognizerDelegate*/{
        var routes = [[CLLocationCoordinate2D]]()
        //try storing images to reduce load time and computation
        //    var markerImages = [UIImage]()
        
        
        var parent : RaceMapView
        var set = false
        var moveCount = 0
        
        
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
            
            parent.alignView?()
            
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
            
            let markerColor = /*isUserDisconnected(index: index) ? */UIColor.randomColorFromSeed(input: index)/* : UIColor.systemGray*/
            
            let mapMarker = MapMarkerUI(frame: CGRect(x: 0, y: 0, width: 60, height: 60), color: markerColor)
            
            let markerImage = mapMarker.asImage()
            
            annotationView.image = markerImage
            
            return annotationView
        }
        
        func isUserDisconnected(index: Int) -> Bool{
            guard SocketIOManager.getInstance.distances.count > 0 else{return true}
            return SocketIOManager.getInstance.users.contains(Array(SocketIOManager.getInstance.distances.keys)[index])
        }
    }
}

struct RaceMap: View {
    
    @Binding var currentView : CurrentView
    @Binding var comingBack : Bool
    
    @State var allPoints = [[CLLocationCoordinate2D]]()
    @State var map = MKMapView(frame: .zero)
    
    @State var addCount = 0
    
    @State var youNewHost = false
    @State var amHost = false
    
    @State var raceStatsShown = false
    
    @State var leaveRacePressed = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    func resetToHome(){
        presentationMode.wrappedValue.dismiss()
        currentView = .home
        comingBack = true
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
            RaceMapView(points: $allPoints, map: $map, alignView: self.alignView)
                
            RepositionButton(map: $map)
                .frame(width: 50, height: 50)
                .offset(x: (UIScreen.main.bounds.width/2 - 50), y: (UIScreen.main.bounds.height/2 - 50))
            
            RaceStats(shown: $raceStatsShown)
            
            RaceStatsButton(raceStatsShown: $raceStatsShown)
                .frame(width: self.raceStatsShown ? UIScreen.main.bounds.height/12 : 50, height: self.raceStatsShown ? UIScreen.main.bounds.height/12 : 50)
                .rotationEffect(.degrees(self.raceStatsShown ? 180 : 0))
                .offset(x: self.raceStatsShown ? 0 : -(UIScreen.main.bounds.width/2 - 50), y: (UIScreen.main.bounds.height/2 - (self.raceStatsShown ? 30 : 50)))
            
            LeaveRaceButton(leaveRacePressed: $leaveRacePressed)
                .frame(width: 50, height: 50)
                .offset(x: -(UIScreen.main.bounds.width/2 - 50), y: -(UIScreen.main.bounds.height/2 - 50))
            
            AlertView(title: "Host Left", text: "You are now the Race Host", trigger: self.$youNewHost)
            
            AlertView(title: "Leave Race", text: "Are you sure you want to leave the Race?", onOk: leaveRace, trigger: self.$leaveRacePressed)
            
            
        }.onAppear{
            SocketIOManager.getInstance.resetToHome = self.resetToHome
            SocketIOManager.getInstance.newHost = self.newHost
            SocketIOManager.getInstance.updatePositionsLabel = self.addToMap
            
            self.showHostText()
        }
    }
    
    func leaveRace(){
        self.leaveRacePressed = false
        
        self.resetToHome()
        
        SocketIOManager.getInstance.leaveRace()
        SocketIOManager.getInstance.inRace = false
        
        self.resetToHome()
    }
    
    func alignView(){
        if(SocketIOManager.getInstance.inRace){
            let me = SocketIOManager.getInstance.positions[SocketIOManager.getInstance.userId]!
            
            let coordinate = me.last
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate!, span: span)
            
            if(me.count > 1){
                let curPos = String(me[me.count-2].latitude)
                let centerPos = String(map.region.center.latitude)
                
                let decimalCount = min(curPos.count, centerPos.count) - 1
                
                if(curPos.prefix(decimalCount) == centerPos.prefix(decimalCount)){
                    map.setRegion(region, animated: true)
                }
            }else{
                map.setRegion(region, animated: true)
            }
        }
    }
}

