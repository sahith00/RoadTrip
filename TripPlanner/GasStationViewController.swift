//
//  GasStationViewController.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/8/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import UIKit
import GoogleMaps
import Foundation
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator


class GasStationViewController: ViewControllerFunctions {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var sensor: Bool?
    var alternatives: Bool?
    var optimized: Bool?
    var waypoints: [AnyObject]?
    var waypointStrings: [String]?
    var endCoords: (lats: [Double], longs: [Double]) = ([], [])
    var startCoords: (lats: [Double], longs: [Double]) = ([], [])
    var distances: [Double] = []
    var midpoints: (lats: [Double], longs: [Double]) = ([], [])
    
    let apiToContact = "https://maps.googleapis.com/maps/api/directions/json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        Alamofire.request(.GET, apiToContact, parameters: ["origin": Address.startAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "destination": Address.endAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "key": "AIzaSyCtJyqEx9hHY11_uU0fUNcTASaFpWy5aWM"])
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
                    
                    self.createMarker(true, title: Address.startAddress, lat: startCoord.lat, long: startCoord.long, mapView: self.mapView)
                    self.createMarker(true, title: Address.endAddress, lat: endCoord.lat, long: endCoord.long, mapView: self.mapView)
                    self.addDirections(JSON as! [NSObject : AnyObject], mapView: self.mapView)
                    
                    var i = 1
                    let len = self.endCoords.lats.count
                    self.callYelp("Hotels", latitude: self.endCoords.lats[0], longitude: self.endCoords.longs[0], mapView: self.mapView)
                    while i < len {
                        if self.distances[i] < 0.05 {
                            self.callYelp("Hotels", latitude: self.endCoords.lats[i], longitude: self.endCoords.longs[i], mapView: self.mapView)
                        }
                        else {
                            let midpoint: (lat: Double, long: Double) = self.findMidpoint(self.startCoords.longs[i], y1: self.startCoords.lats[i], x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                            self.callYelp("Hotels", latitude: midpoint.lat, longitude: midpoint.long, mapView: self.mapView)
                            if self.distances[i] < 0.1 {
                                let midpoint2: (lat: Double, long: Double) = self.findMidpoint(midpoint.long, y1: midpoint.lat, x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                                self.callYelp("Hotels", latitude: midpoint2.lat, longitude: midpoint2.long, mapView: self.mapView)
                                let midpoint3: (lat: Double, long: Double) = self.findMidpoint(self.startCoords.longs[i], y1: self.startCoords.lats[i], x2: midpoint.long, y2: midpoint.lat)
                                self.callYelp("Hotels", latitude: midpoint3.lat, longitude: midpoint3.long, mapView: self.mapView)
                            }
                            else {
                                var startMidpoints: [(lat: Double, long: Double)] = []
                                var endMidpoints: [(lat: Double, long: Double)] = []
                                startMidpoints.append(midpoint)
                                endMidpoints.append(midpoint)
                                print(startMidpoints, endMidpoints)
                                for j in 1 ... 4 {
                                    let startMidpoint: (lat: Double, long: Double) = self.findMidpoint(startMidpoints[j-1].long, y1: startMidpoints[j-1].lat, x2: self.startCoords.longs[i], y2: self.startCoords.lats[i])
                                    let endMidpoint: (lat: Double, long: Double) = self.findMidpoint(endMidpoints[j-1].long, y1: endMidpoints[j-1].lat, x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                                    startMidpoints.append(startMidpoint)
                                    endMidpoints.append(endMidpoint)
                                    self.callYelp("Hotels", latitude: startMidpoint.lat, longitude: startMidpoint.long, mapView: self.mapView)
                                    self.callYelp("Hotels", latitude: endMidpoint.lat, longitude: endMidpoint.long, mapView: self.mapView)
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
