//
//  OMCLocationUpdates.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/4/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import Foundation
import CoreLocation

extension OMCChatVC {
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            DispatchQueue.main.async {
                self.locationManager.startUpdatingLocation()
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        UserCurrLocation.currLoc = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}
