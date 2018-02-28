//
//  OMCMapView.swift
//  ChatBots
//
//  Created by Jay Vachhani on 11/3/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

import Foundation
import MapKit

extension OMCChatBubbleView : MKMapViewDelegate {
    
    func setupMapView(_map:NSDictionary?){
        
        let startY:CGFloat = lblHeight! < 25 ? 25 : lblHeight!
        let startX = 0.0
        
        let mapV:MKMapView = MKMapView.init(frame: CGRect(x: CGFloat(startX), y: startY, width: self.frame.width , height: 120))
        
        mapV.mapType = MKMapType.standard
        mapV.isZoomEnabled = true
        mapV.showsUserLocation = true
        mapV.delegate = self;
        self.addSubview(mapV)
        self.bringSubview(toFront: mapV)
        mapView = mapV;
        
        let coord:CLLocationCoordinate2D;
        
        if ( _map != nil ) {
            
            coord = CLLocationCoordinate2D.init(latitude: (_map?.object(forKey: "lat") as! NSString).doubleValue , longitude: (_map?.object(forKey: "long") as! NSString).doubleValue)
            
            addAnnotionFor(coord, name: _map?.object(forKey: "name") as! String, mapV:mapV );
        }
        else{
            
            let centerPin:UIImageView = UIImageView.init(frame: CGRect(x: (self.frame.width/2)-20, y: startY+(mapV.frame.height/2)-25, width: 50 , height: 50) );
            centerPin.image = UIImage.init(named: "map-pin.png")
            centerPin.alpha = 0.75;
            centerPin.isUserInteractionEnabled = false;
            self.addSubview(centerPin);
            self.bringSubview(toFront: centerPin);
            
            let btn:UIButton = UIButton.init(frame: CGRect(x: 10, y: startY+(mapV.frame.height)+5, width: mapV.bounds.size.width , height: 30))
            btn.setTitle("Send", for: UIControlState.normal)
            btn.addTarget(self, action: #selector(OMCChatBubbleView.btnMapConfirmSend ), for: UIControlEvents.touchUpInside)
            self.addSubview(btn);
            
            zoomInToUserLocation(centerPin);
        }
        
        viewHeight = lblHeight! + 160.0;
        viewWidth = mapV.frame.maxX;
        if( viewWidth! < 150 ){
            viewWidth = 150
        }
    }
    
    func btnMapConfirmSend() -> Void {

        mapView?.isUserInteractionEnabled = false;
        mapView?.delegate = nil;
        mapView?.showsUserLocation = false;
        labelChatText?.text = "Confirmed"
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kchoiceSelectedOrChatEntered), object: mapView?.centerCoordinate )

    }
    
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    func addAnnotionFor(_ coordinate:CLLocationCoordinate2D, name:String, mapV:MKMapView) -> Void {
        
        let annotation = MKPointAnnotation()
        annotation.title = ""
        annotation.subtitle = name
        annotation.coordinate = coordinate
        
        mapV.addAnnotation(annotation)
        
        let region = MKCoordinateRegionMakeWithDistance(
            (coordinate), 2000, 2000)
        
        mapV.setRegion(region, animated: true)
    }
    
    func zoomInToUserLocation(_ sender: AnyObject) {
        
        let userLocation = mapView?.userLocation
        
        if( userLocation?.isUpdating == true ){
            print("Waiting, while it retrieves current location.")
            let when = DispatchTime.now() + 0.5 //
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.zoomNowToUserLocation()
            }
        }
        else{
            zoomNowToUserLocation()
        }
    }
    
    func zoomNowToUserLocation() -> Void {
        
        let userLocation = mapView?.userLocation
        
        if ( userLocation?.coordinate != nil ) {
            var region = MKCoordinateRegion(center: (userLocation?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            region.center = (mapView?.userLocation.coordinate)!
            mapView?.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotationIdentifier = "aPin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "map-pin")
        
        return annotationView
    }
}
