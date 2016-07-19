//
//  HotelViewController.swift
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

class HotelViewController: UIViewController {

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
                    
                    self.createMarker(Address.startAddress, lat: startCoord.lat, long: startCoord.long)
                    self.createMarker(Address.endAddress, lat: endCoord.lat, long: endCoord.long)
                    self.addDirections(JSON as! [NSObject : AnyObject])
                    
                    var i = 0
                    let len = self.endCoords.lats.count
                    while i < len {
                        if self.distances[i] > 0.05 {
                            YelpClient.sharedInstance.searchWithTerm("Hotels", lat: self.endCoords.lats[i], long: self.endCoords.longs[i], completion: { (hotels, error) in
                                if hotels != nil {
                                    for hotel in hotels {
                                        if let lat = hotel.lat {
                                            if let long = hotel.long {
                                                self.createMarker(hotel.name!, lat: lat, long: long)
                                            }
                                        }
                                    }
                                }
                            })
                        }
                        else {
                            let midpoint: (lat: Double, long: Double) = self.findMidpoint(self.startCoords.longs[i], y1: self.startCoords.lats[i], x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                            print(midpoint)
                            YelpClient.sharedInstance.searchWithTerm("Hotels", lat: midpoint.lat, long: midpoint.long, completion: { (hotels, error) in
                                if hotels != nil {
                                    for hotel in hotels {
                                        if let lat = hotel.lat {
                                            if let long = hotel.long {
                                                self.createMarker(hotel.name!, lat: lat, long: long)
                                            }
                                        }
                                    }
                                }
                            })
                        }
                        i+=1
                    }
                }
        }
    }
    
    func createMarker(title: String, lat: Double, long: Double) {
        let marker = GMSMarker()
        let geocoder = GMSGeocoder()
        marker.position = CLLocationCoordinate2DMake(lat, long)
        geocoder.reverseGeocodeCoordinate(marker.position) { (response, error) in
            if title == "" {
                marker.title = response?.firstResult()?.addressLine1()
            }
            else {
                marker.title = title
            }
            marker.snippet = response?.firstResult()?.locality
        }
        marker.map = self.mapView
    }
    
    func createPath(route: String) {
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.redColor()
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView
    }
    
    func addDirections(json: [NSObject : AnyObject]) {
        let routes: [NSObject : AnyObject] = (json["routes"]![0] as! [NSObject : AnyObject])
        let route: [NSObject : AnyObject] = (routes["overview_polyline"] as! [NSObject : AnyObject])
        let overview_route: String = (route["points"] as! String)
        createPath(overview_route)
    }
    
    func convertPointsToEncodedPath(points: [AnyObject]) -> String{
        var ans: String = ""
        //print(points)
        print(points.count)
        print(points[0] as! String)
        for point in points {
            let strpoint = point as! String
            ans += strpoint
        }
        return ans
    }
    
    func findDistance(x1: Double, y1: Double, x2: Double, y2: Double) -> Double{
        let d1: Double = x2 - x1
        let d2: Double = y2 - y1
        let ans = sqrt((d1 * d1) + (d2 * d2))
        return ans
    }
    
    func findMidpoint(x1: Double, y1: Double, x2: Double, y2: Double) -> (Double, Double) {
        let p1: Double = (x1 + x2) * 0.5
        let p2: Double = (y1 + y2) * 0.5
        return (p2, p1)
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
