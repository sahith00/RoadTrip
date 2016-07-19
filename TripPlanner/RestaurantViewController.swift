//
//  RestaurantViewController.swift
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


class RestaurantViewController: UIViewController {
    
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
                    
                    self.createMarker(Address.startAddress, lat: startCoord.lat, long: startCoord.long)
                    self.createMarker(Address.endAddress, lat: endCoord.lat, long: endCoord.long)
                    self.addDirections(JSON as! [NSObject : AnyObject])
                    
                    var i = 0
                    let len = endCoords.lats.count
                    while i < len {
                        YelpClient.sharedInstance.searchWithTerm("Restaurants", lat: endCoords.lats[i], long: endCoords.longs[i], completion: { (restaurants, error) in
                            if restaurants != nil {
                                for restaurant in restaurants {
                                    if let lat = restaurant.lat {
                                        if let long = restaurant.long {
                                            self.createMarker(restaurant.name!, lat: lat, long: long)
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
        var routes: [NSObject : AnyObject] = (json["routes"]![0] as! [NSObject : AnyObject])
        var route: [NSObject : AnyObject] = (routes["overview_polyline"] as! [NSObject : AnyObject])
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
