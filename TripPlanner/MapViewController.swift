//
//  MapViewController.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/25/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import Foundation
import GoogleMaps
import Alamofire
import SwiftyJSON

class MapViewController: ViewControllerFunctions {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var businessSelector: UIBarButtonItem!
    
    var route: Route?
    var overviewRoute: String?
    
    var startCoord: (lat: Double, long: Double) = (0, 0)
    var endCoord: (lat: Double, long: Double) = (0, 0)
    var startCoords: (lats: [Double], longs: [Double]) = ([], [])
    var endCoords: (lats: [Double], longs: [Double]) = ([], [])
    var distances: [Double] = []
    var midpoints: (lats: [Double], longs: [Double]) = ([], [])
    
    var gasStations: (names: [String], lats: [Double], longs: [Double]) = ([], [], [])
    var hotels: (names: [String], lats: [Double], longs: [Double]) = ([], [], [])
    var restaurants: (names: [String], lats: [Double], longs: [Double]) = ([], [], [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let apiToContact = "https://maps.googleapis.com/maps/api/directions/json"
        
        route = RealmHelper.retrieveLastRoute()
        
        Alamofire.request(.GET, apiToContact, parameters: ["origin": route!.startAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "destination": route!.endAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "key": "AIzaSyCtJyqEx9hHY11_uU0fUNcTASaFpWy5aWM"])
            .responseJSON { response in
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    let routes = json["routes"][0]
                    let route = routes["overview_polyline"]
                    self.overviewRoute = (route["points"].string)
                    
                    let count = json["routes"][0]["legs"][0]["steps"].count
                    
                    var index = 0
                    
                    while index < count {
                        let routes = json["routes"]
                        let route = routes[0]
                        let legs = route["legs"]
                        let leg = legs[0]
                        let steps = leg["steps"]
                        let step = steps[index]
                        let endLat = step["end_location"]["lat"]
                        let endLong = step["end_location"]["lng"]
                        let startLat = step["start_location"]["lat"]
                        let startLong = step["start_location"]["lng"]
                        self.endCoords.lats.append(endLat.doubleValue)
                        self.endCoords.longs.append(endLong.doubleValue)
                        self.startCoords.lats.append(startLat.doubleValue)
                        self.startCoords.longs.append(startLong.doubleValue)
                        self.distances.append(self.findDistance(startLong.doubleValue, y1: startLat.doubleValue, x2: endLong.doubleValue, y2: endLat.doubleValue))
                        index+=1
                    }
                    
                    self.startCoord = (self.startCoords.lats[0], self.startCoords.longs[0])
                    self.endCoord = (json["routes"][0]["legs"][0]["end_location"]["lat"].doubleValue, json["routes"][0]["legs"][0]["end_location"]["lng"].doubleValue)
                    
                    self.setCamera()
                    self.showRoute()
                }
        }
    }
    
    @IBAction func businessSelect(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let gasStationAction = UIAlertAction(title: "Gas Stations", style: .Default) { (action) in
            self.mapView.clear()
            self.showRoute()
            self.callFullYelp("Gas Stations", type: self.gasStations)
            self.setCamera()
        }
        let hotelAction = UIAlertAction(title: "Hotels", style: .Default) { (action) in
            self.mapView.clear()
            self.showRoute()
            self.callFullYelp("Hotels", type: self.hotels)
            self.setCamera()
        }
        let restaurantAction = UIAlertAction(title: "Restaurants", style: .Default) { (action) in
            self.mapView.clear()
            self.showRoute()
            self.callFullYelp("Restaurants", type: self.restaurants)
            self.setCamera()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(gasStationAction)
        alertController.addAction(hotelAction)
        alertController.addAction(restaurantAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setCamera() {
        let distance = self.findDistance(self.startCoord.long, y1: self.startCoord.lat, x2: self.endCoord.long, y2: self.endCoord.lat)
        var zoom: Float = 15
        if distance > 10 {
            zoom = 3
        }
        else if distance > 5 {
            zoom = 4
        }
        else if distance > 2 {
            zoom = 6
        }
        else if distance > 1.2 {
            zoom = 8
        }
        else if distance > 0.2 {
            zoom = 10
        }
        else if distance > 0.02 {
            zoom = 14
        }
        let midpoint: (lat: Double, long: Double) = self.findMidpoint(self.startCoord.long, y1: self.startCoord.lat, x2: self.endCoord.long, y2: self.endCoord.lat)
        let camera = GMSCameraPosition.cameraWithLatitude(midpoint.lat, longitude: midpoint.long, zoom: zoom)
        self.mapView.camera = camera
    }
    
    func showRoute() {
        self.createMarker(true, title: self.route!.startAddress, rating: nil, lat: self.startCoord.lat, long: self.startCoord.long, mapView: self.mapView)
        self.createMarker(true, title: self.route!.endAddress, rating: nil, lat: self.endCoord.lat, long: self.endCoord.long, mapView: self.mapView)
        self.createPath(self.overviewRoute!, mapView: self.mapView)
    }
    
    func callFullYelp(business: String, type: ([String], [Double], [Double])) {
        var i = 1
        let len = self.endCoords.lats.count
        var radius = (self.findAverage(self.distances)/3)*1e6
        if radius > 40000 {
            radius = 40000
        }
        
        self.callYelp(business, places: type, latitude: self.endCoords.lats[0], longitude: self.endCoords.longs[0], radius: radius, mapView: self.mapView)
        
        while i < len {
            
            if self.distances[i] < 0.02 {
                
                self.callYelp(business, places: type, latitude: self.endCoords.lats[i], longitude: self.endCoords.longs[i], radius: radius, mapView: self.mapView)
            }
            else {
                
                let midpoint: (lat: Double, long: Double) = self.findMidpoint(self.startCoords.longs[i], y1: self.startCoords.lats[i], x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                
                self.callYelp(business, places: type, latitude: midpoint.lat, longitude: midpoint.long, radius: radius, mapView: self.mapView)
                
                if self.distances[i] < 0.05 {
                    
                    let midpoint2: (lat: Double, long: Double) = self.findMidpoint(midpoint.long, y1: midpoint.lat, x2: self.endCoords.longs[i], y2: self.endCoords.lats[i])
                    let midpoint3: (lat: Double, long: Double) = self.findMidpoint(self.startCoords.longs[i], y1: self.startCoords.lats[i], x2: midpoint.long, y2: midpoint.lat)
                    
                    self.callYelp(business, places: type, latitude: midpoint2.lat, longitude: midpoint2.long, radius: radius, mapView: self.mapView)
                    self.callYelp(business, places: type, latitude: midpoint3.lat, longitude: midpoint3.long, radius: radius, mapView: self.mapView)
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
                        
                        self.callYelp(business, places: type, latitude: startMidpoint.lat, longitude: startMidpoint.long, radius: radius, mapView: self.mapView)
                        self.callYelp(business, places: type, latitude: endMidpoint.lat, longitude: endMidpoint.long, radius: radius, mapView: self.mapView)
                    }
                }
            }
            i+=1
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