//
//  LocationManager.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 7/29/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import MapKit

//class LocationManager: NSObject, ObservableObject{
//    private let locationManager = CLLocationManager()
//    @Published var location: CLLocation? = nil
//
//    override init(){
//        super.init()
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.distanceFilter = kCLDistanceFilterNone
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.startUpdatingLocation()
//    }
//}
//
//extension LocationManager: CLLocationManagerDelegate{
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else{
//            return
//        }
//
//        self.location = location
//
//    }
//}

class LocationManager: NSObject{
    @objc static let getInstance = LocationManager()

    var locationManager = CLLocationManager()
    
    func getLocation() -> CLLocation?{
        var currentLoc: CLLocation? = nil
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            currentLoc = self.locationManager.location
//            print(currentLoc!.coordinate.latitude)
//            print(currentLoc!.coordinate.longitude)
        }else{
            print("couldn't get location")
        }
        
        return currentLoc
    }
    
    func start(){
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func stop(){
        self.locationManager.stopUpdatingLocation()
    }
}
