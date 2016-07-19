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
    
    let apiToContact = "https://maps.googleapis.com/maps/api/directions/json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        Alamofire.request(.GET, apiToContact, parameters: ["origin": Address.startAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "destination": Address.endAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "key": "AIzaSyCtJyqEx9hHY11_uU0fUNcTASaFpWy5aWM"])
            .responseJSON { response in
                if let JSON = response.result.value {
                    
                    let count = JSON["routes"]!![0]["legs"]!![0]["steps"]!?.count
                    
                    var index = 0
                    var endCoords: (lats: [Double], longs: [Double]) = ([], [])
                    var startCoords: (lats: [Double], longs: [Double]) = ([], [])
                    
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
                        endCoords.lats.append(endLat.doubleValue)
                        endCoords.longs.append(endLong.doubleValue)
                        startCoords.lats.append(startLat.doubleValue)
                        startCoords.longs.append(startLong.doubleValue)
                        index+=1
                    }
                    
                    let startCoord: (lat:Double, long:Double) = (startCoords.lats[0], startCoords.longs[0])
                    let endCoord: (lat:Double, long:Double) = (JSON["routes"]!![0]["legs"]!![0]["end_location"]!!["lat"]!!.doubleValue, JSON["routes"]!![0]["legs"]!![0]["end_location"]!!["lng"]!!.doubleValue)
                    
                    let camera = GMSCameraPosition.cameraWithLatitude(startCoord.lat, longitude: startCoord.long, zoom: 8)
                    self.mapView.camera = camera
                    
                    self.createMarker(Address.startAddress, lat: startCoord.lat, long: startCoord.long, mapView: self.mapView)
                    self.createMarker(Address.endAddress, lat: endCoord.lat, long: endCoord.long, mapView: self.mapView)
                    self.addDirections(JSON as! [NSObject : AnyObject], mapView: self.mapView)
                    
                    var i = 0
                    let len = endCoords.lats.count
                    while i < len {
                        YelpClient.sharedInstance.searchWithTerm("Gas Stations", lat: endCoords.lats[i], long: endCoords.longs[i], completion: { (restaurants, error) in
                            if restaurants != nil {
                                for restaurant in restaurants {
                                    if let lat = restaurant.lat {
                                        if let long = restaurant.long {
                                            self.createMarker(restaurant.name!, lat: lat, long: long, mapView: self.mapView)
                                        }
                                    }
                                }
                            }
                        })
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
