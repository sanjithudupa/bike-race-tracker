//
//  Map.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 7/29/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable{
    
    func makeCoordinator() -> MapView.Coordinator {
        return MapView.Coordinator(parent1: self)
    }
    
    @Binding var points : [[CLLocationCoordinate2D]]

    func makeUIView(context: Context) -> MKMapView{
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.mapType = .mutedStandard
        
        return map
    }
    
    func updateUIView(_ view: MKMapView, context: Context){
        
        guard points.count > 0 else { return }
        
        let coordinate = points[0].last
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate!, span: span)
        
        view.setRegion(region, animated: true)
        
        //clear map
//        if !view.overlays.isEmpty {
//            view.removeOverlays(view.overlays)
//        }
        
        let curOverlays = view.overlays
        
//        if !view.annotations.isEmpty { view.removeAnnotations(view.annotations)
//        }
        
        
        //draw polylines
        var polyLine:MKPolyline
        var landmark:LandmarkAnnotation
        var count = 0
        
//        mapViewDelegate.routes = []
        
        for point in self.points{
            polyLine = MKPolyline(coordinates: point, count: self.points[count].count);
            polyLine.title = String(count);
            view.addOverlay(polyLine);
            count += 1
            
//            mapViewDelegate.routes.append(point)
            
            //draw markers
            landmark = LandmarkAnnotation(title: String(count), subtitle: "landmark", coordinate: point.last!)
            
            view.addAnnotation(landmark)
        }
        
        view.removeOverlays(curOverlays)
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate{
        var routes = [[CLLocationCoordinate2D]]()
        //try storing images to reduce load time and computation
        //    var markerImages = [UIImage]()
        
        
        var parent : MapView
        
        init(parent1: MapView){
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

struct Map: View {
//    @Binding var showing : CurrentView
    
    @Binding var currentView : CurrentView

//    var points =
    @State var additions = [[CLLocationCoordinate2D(latitude: 21.124083, longitude: 79.1145274), CLLocationCoordinate2D(latitude: 21.1245418, longitude: 79.1160327), CLLocationCoordinate2D(latitude: 21.1394636, longitude: 79.1199755), CLLocationCoordinate2D(latitude: 21.1243668, longitude: 79.1037889)], [CLLocationCoordinate2D(latitude: 21.122083, longitude: 79.1135274), CLLocationCoordinate2D(latitude: 21.1235418, longitude: 79.1150327), CLLocationCoordinate2D(latitude: 21.1384636, longitude: 79.1189755), CLLocationCoordinate2D(latitude: 21.1233668, longitude: 79.1027889)]]
    
    @State var allPoints = [[CLLocationCoordinate2D(latitude: 21.1433668, longitude: 79.1047889)], [CLLocationCoordinate2D(latitude: 21.1233668, longitude: 79.1027889)]]
    
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
    
    var body: some View {
        ZStack{
            MapView(points: $allPoints)
            Image(systemName: "plus.rectangle.fill")
                .resizable()
                .frame(width: 70, height: 50)
                .offset(y:250)
                .onTapGesture {
                    print(SocketIOManager.getInstance.endpoint)
//                    for _ in self.additions[0]{
                    if(self.additions.count > 0 && self.addCount < self.additions[0].count){
                        for i in 0..<self.additions.count{
                            self.allPoints[i].append(self.additions[i][self.addCount])
                        }
                                                
                                                
                    //                            self.allPoints[1].append(self.additions[1][self.addCount])
                                            
                        self.addCount += 1
                        
                    }
//                    }
                    
                    
                }
            
            if(self.$amHost.wrappedValue){
                Text("You are the Host")
                    .offset(y: UIScreen.main.bounds.height/4 + 70)
            }
            
            AlertView(title: "Host Left", text: "You are now the Race Host", trigger: self.$youNewHost)
            
            
            
//            Text("Position " +  + "  : " + String(self.addCount))
        }.onAppear{
            SocketIOManager.getInstance.resetToHome = self.resetToHome
            SocketIOManager.getInstance.newHost = self.newHost
            
            self.showHostText()
        }
    }
}

extension UIColor {
    static let seedColors:[Int: UIColor] = [0:UIColor.systemGreen, 1:UIColor.systemRed, 2:UIColor.systemBlue, 3:UIColor.systemOrange, 4:UIColor.systemPink, 5:UIColor.systemPurple, 6:UIColor.systemYellow, 7:UIColor.systemTeal, 8:UIColor.black, 9:UIColor.systemGray]

    public static func randomColorFromSeed(input: Int) -> UIColor {
        
        if(input <= 9){
            return seedColors[input] ?? UIColor.green
        }
        
        var total: Int = 0
        let seed = String(input + 1)
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}


final class MapMarkerUI: UIView {
    var height:CGFloat = 30.0
    var width:CGFloat = 30.0
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        
        let botttomCircle = UIView(frame: CGRect(x: frame.width/4, y: frame.height/4, width: width, height: height))
        
        botttomCircle.layer.cornerRadius = height/2
        //frame.height/2 - 5]
        
        // border radius

        // border
        botttomCircle.layer.borderColor = color.cgColor
        botttomCircle.layer.backgroundColor = color.cgColor
        botttomCircle.layer.borderWidth = 1.5

        // drop shadow
        botttomCircle.layer.shadowColor = UIColor.black.cgColor
        botttomCircle.layer.shadowOpacity = 0.8
        botttomCircle.layer.shadowRadius = 3.5
        botttomCircle.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addSubview(botttomCircle)
        
        let topCircle = UIView(frame: CGRect(x: frame.width/4 + 5, y: frame.height/4 + 5, width: width/1.5, height: height/1.5))
        
        topCircle.layer.cornerRadius = height/3
        
        topCircle.layer.borderColor = UIColor.white.cgColor
        topCircle.layer.backgroundColor = UIColor.white.cgColor
        topCircle.layer.borderWidth = 1.5

        // drop shadow
        topCircle.layer.shadowColor = UIColor.black.cgColor
        topCircle.layer.shadowOpacity = 0.8
        topCircle.layer.shadowRadius = 4
        topCircle.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addSubview(topCircle)
        
//        let triangle = UIView(frame: frame)
//        let triangleLayer = CAShapeLayer()
//        let trianglePath = UIBezierPath()
//
//        trianglePath.move(to: CGPoint(x: frame.midX, y: frame.height/3.5 + 2))
//        trianglePath.addLine(to: CGPoint(x: frame.midX + 10, y: frame.height/2.75 + 2))
//        trianglePath.addLine(to: CGPoint(x: frame.midX, y: 2 * (frame.height/3) + 2))
//        trianglePath.addLine(to: CGPoint(x: frame.midX - 10, y: frame.height/2.75 + 2))
//
//
//        triangleLayer.path = trianglePath.cgPath
//        triangleLayer.cornerRadius = 5
//        triangle.layer.addSublayer(triangleLayer)
//
//        triangle.layer.shadowColor = UIColor.black.cgColor
//        triangle.layer.shadowOpacity = 0.8
//        triangle.layer.shadowRadius = 3.5
//        triangle.layer.shadowOffset = CGSize(width: 0, height: 0)
//
//        triangleLayer.fillColor = color.cgColor
//
//
//
//        addSubview(triangle)
//
        
//        makeCircleWithShadow(radius: frame.height/2 - 5, shadowOff: 2, color: color)
        
    }
    
    func makeCircleWithShadow(radius: CGFloat, shadowOff: CGFloat, color: UIColor){
        let shadowPath = UIBezierPath(arcCenter: CGPoint(x: frame.midX, y: frame.midY), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = shadowPath.cgPath

        shadowLayer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.midX, y: frame.midY), radius: radius - shadowOff, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath

        circleLayer.fillColor = color.cgColor
        
//        layer.addSublayer(shadowLayer)
        layer.addSublayer(circleLayer)
        
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

