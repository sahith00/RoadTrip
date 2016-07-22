//
//  RestaurantViewController.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/8/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import UIKit
import Foundation
import Dispatch
import GoogleMaps
import Alamofire

class RestaurantViewController: ViewControllerFunctions {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var address: Address?
    
    var sensor: Bool?
    var alternatives: Bool?
    var optimized: Bool?
    var waypoints: [AnyObject]?
    var waypointStrings: [String]?
    var endCoords: (lats: [Double], longs: [Double]) = ([], [])
    var startCoords: (lats: [Double], longs: [Double]) = ([], [])
    var distances: [Double] = []
    var midpoints: (lats: [Double], longs: [Double]) = ([], [])
    var markers: [GMSMarker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let apiToContact = "https://maps.googleapis.com/maps/api/directions/json"
        let business = "Restaurants"
        
        address = Array(RealmHelper.retrieveAddresses())[0]
        
        Alamofire.request(.GET, apiToContact, parameters: ["origin": address!.startAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "destination": address!.endAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "key": "AIzaSyCtJyqEx9hHY11_uU0fUNcTASaFpWy5aWM"])
            .responseJSON { response in
                if let JSON = response.result.value {
                    
                    let count = JSON["routes"]!![0]["legs"]!![0]["steps"]!?.count
                    
                    var index = 0
                    
                    while index < count {
                        let routes = JSON["routes"] as! [AnyObject]
                        let route = routes[0]
                        let legs = route["legs"] as! [AnyObject]
                        let leg = legs[0]
                        let steps = leg["steps"] as! [AnyObject]
                        let step = steps[index]
                        let endLat = step["end_location"]!!["lat"]!!
                        let endLong = step["end_location"]!!["lng"]!!
                        let startLat = step["start_location"]!!["lat"]!!
                        let startLong = step["start_location"]!!["lng"]!!
                        self.endCoords.lats.append(endLat.doubleValue)
                        self.endCoords.longs.append(endLong.doubleValue)
                        self.startCoords.lats.append(startLat.doubleValue)
                        self.startCoords.longs.append(startLong.doubleValue)
                        self.distances.append(self.findDistance(startLong.doubleValue, y1: startLat.doubleValue, x2: endLong.doubleValue, y2: endLat.doubleValue))
                        index+=1
                    }
                    
                    let startCoord: (lat:Double, long:Double) = (self.startCoords.lats[0], self.startCoords.longs[0])
                    let endCoord: (lat:Double, long:Double) = (JSON["routes"]!![0]["legs"]!![0]["end_location"]!!["lat"]!!.doubleValue, JSON["routes"]!![0]["legs"]!![0]["end_location"]!!["lng"]!!.doubleValue)
                    
                    let camera = GMSCameraPosition.cameraWithLatitude(startCoord.lat, longitude: startCoord.long, zoom: 8)
                    self.mapView.camera = camera
                    
                    self.createMarker(true, title: self.address!.startAddress, lat: startCoord.lat, long: startCoord.long, mapView: self.mapView)
                    self.createMarker(true, title: self.address!.endAddress, lat: endCoord.lat, long: endCoord.long, mapView: self.mapView)
                    self.addDirections(JSON as! [NSObject : AnyObject], mapView: self.mapView)
                    
                    var i = 1
                    let len = self.endCoords.lats.count
                    var radius = (self.findAverage(self.distances)/2)*1e6
                    if radius > 40000 {
                        radius = 40000
                    }
                    
                    self.callYelp(business, latitude: self.endCoords.lats[0], longitude: self.endCoords.longs[0], radius: radius, mapView: self.mapView, markers: self.markers)
                    
                    while i < len {
                        
                        if self.distances[i] < 0.02 {
                            
                            self.callYelp(business, latitude: self.endCoords.lats[i], longitude: self.endCoords.longs[i], radius: radius, mapView: self.mapView, markers: self.markers)
                        }
                        else {
                            
                            let midpoint: (lat: Double, long: Double) = self.findMidpoint(self.startCoords.longs[i], y1: self.startCoords.lats[i], x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                            
                            self.callYelp(business, latitude: midpoint.lat, longitude: midpoint.long, radius: radius, mapView: self.mapView, markers: self.markers)
                            
                            if self.distances[i] < 0.05 {
                                
                                let midpoint2: (lat: Double, long: Double) = self.findMidpoint(midpoint.long, y1: midpoint.lat, x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                                let midpoint3: (lat: Double, long: Double) = self.findMidpoint(self.startCoords.longs[i], y1: self.startCoords.lats[i], x2: midpoint.long, y2: midpoint.lat)
                                
                                self.callYelp(business, latitude: midpoint2.lat, longitude: midpoint2.long, radius: radius, mapView: self.mapView, markers: self.markers)
                                self.callYelp(business, latitude: midpoint3.lat, longitude: midpoint3.long, radius: radius, mapView: self.mapView, markers: self.markers)
                            }
                            else {
                                
                                var startMidpoints: [(lat: Double, long: Double)] = []
                                var endMidpoints: [(lat: Double, long: Double)] = []
                                startMidpoints.append(midpoint)
                                endMidpoints.append(midpoint)
                                
                                for j in 1 ... 5 {
                                    
                                    let startMidpoint: (lat: Double, long: Double) = self.findMidpoint(startMidpoints[j-1].long, y1: startMidpoints[j-1].lat, x2: self.startCoords.longs[i], y2: self.startCoords.lats[i])
                                    let endMidpoint: (lat: Double, long: Double) = self.findMidpoint(endMidpoints[j-1].long, y1: endMidpoints[j-1].lat, x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                                    startMidpoints.append(startMidpoint)
                                    endMidpoints.append(endMidpoint)
                                    
                                    self.callYelp(business, latitude: startMidpoint.lat, longitude: startMidpoint.long, radius: radius, mapView: self.mapView, markers: self.markers)
                                    self.callYelp(business, latitude: endMidpoint.lat, longitude: endMidpoint.long, radius: radius, mapView: self.mapView, markers: self.markers)
                                }
                            }
                        }
                        i+=1
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
