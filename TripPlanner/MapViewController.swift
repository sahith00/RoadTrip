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
    
    var currentBusiness: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let apiToContact = "https://maps.googleapis.com/maps/api/directions/json"
        
        route = RealmHelper.retrieveLastRoute()
        //print(route)
        
        mapView.delegate = self
        
        Alamofire.request(.GET, apiToContact, parameters: ["origin": route!.startAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "destination": route!.endAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "key": "AIzaSyCtJyqEx9hHY11_uU0fUNcTASaFpWy5aWM"])
            .responseJSON { response in
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    //print(json)
                    if json["routes"].count > 0 {
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
                    else {
                        //let camera = GMSCameraPosition()
                        //self.mapView.camera = camera
                    }
                }
        }
    }
    
    @IBAction func businessSelect(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Choose Business", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let gasStationAction = UIAlertAction(title: "Auto Services", style: .Default) { (action) in
            if self.currentBusiness != "Gas Stations" {
                self.mapView.clear()
                self.showRoute()
                self.callFullYelp("Gas Stations", type: self.gasStations)
                self.setCamera()
                self.currentBusiness = "Gas Stations"
            }
            else {
                self.mapView.clear()
                self.showRoute()
                self.currentBusiness = ""
            }
        }
        let hotelAction = UIAlertAction(title: "Hotels", style: .Default) { (action) in
            if self.currentBusiness != "Hotels" {
                self.mapView.clear()
                self.showRoute()
                self.callFullYelp("Hotels", type: self.hotels)
                self.setCamera()
                self.currentBusiness = "Hotels"
            }
            else {
                self.mapView.clear()
                self.showRoute()
                self.currentBusiness = ""
            }
        }
        let restaurantAction = UIAlertAction(title: "Restaurants", style: .Default) { (action) in
            if self.currentBusiness != "Restaurants" {
                self.mapView.clear()
                self.showRoute()
                self.callFullYelp("Restaurants", type: self.restaurants)
                self.setCamera()
                self.currentBusiness = "Restaurants"
            }
            else {
                self.mapView.clear()
                self.showRoute()
                self.currentBusiness = ""
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(gasStationAction)
        alertController.addAction(hotelAction)
        alertController.addAction(restaurantAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setCamera() {
        let distance = findDistance(startCoord.long, y1: startCoord.lat, x2: endCoord.long, y2: endCoord.lat)
        print(distance)
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
        
        let midpoint: (lat: Double, long: Double) = findMidpoint(startCoord.long, y1: startCoord.lat, x2: endCoord.long, y2: endCoord.lat)
        let camera = GMSCameraPosition.cameraWithLatitude(midpoint.lat, longitude: midpoint.long, zoom: zoom)
        mapView.camera = camera
        //mapView.mapType = kGMSTypeSatellite
    }
    
    func showRoute() {
        createMarker(true, title: route!.startAddress, url: nil, rating: nil, lat: startCoord.lat, long: startCoord.long, mapView: mapView)
        createMarker(true, title: route!.endAddress, url: nil, rating: nil, lat: endCoord.lat, long: endCoord.long, mapView: mapView)
        createPath(overviewRoute!, mapView: mapView)
    }
    
    func callFullYelp(business: String, type: ([String], [Double], [Double])) {
        var i = 1
        let len = endCoords.lats.count
        var radius = (findAverage(distances)/3)*1e6
        if radius > 40000 {
            radius = 40000
        }
        
        callYelp(business, places: type, latitude: endCoords.lats[0], longitude: endCoords.longs[0], radius: radius, mapView: mapView)
        
        while i < len {
            
            if distances[i] < 0.02 {
                
                callYelp(business, places: type, latitude: endCoords.lats[i], longitude: endCoords.longs[i], radius: radius, mapView: mapView)
            }
            else {
                
                let midpoint: (lat: Double, long: Double) = findMidpoint(startCoords.longs[i], y1: startCoords.lats[i], x2: endCoords.longs[i], y2: endCoords.lats[i])
                
                callYelp(business, places: type, latitude: midpoint.lat, longitude: midpoint.long, radius: radius, mapView: mapView)
                
                if distances[i] < 0.05 {
                    
                    let midpoint2: (lat: Double, long: Double) = findMidpoint(midpoint.long, y1: midpoint.lat, x2: endCoords.longs[i], y2: endCoords.lats[i])
                    let midpoint3: (lat: Double, long: Double) = findMidpoint(startCoords.longs[i], y1: startCoords.lats[i], x2: midpoint.long, y2: midpoint.lat)
                    
                    callYelp(business, places: type, latitude: midpoint2.lat, longitude: midpoint2.long, radius: radius, mapView: mapView)
                    callYelp(business, places: type, latitude: midpoint3.lat, longitude: midpoint3.long, radius: radius, mapView: mapView)
                }
                else {
                    
                    var startMidpoints: [(lat: Double, long: Double)] = []
                    var endMidpoints: [(lat: Double, long: Double)] = []
                    startMidpoints.append(midpoint)
                    endMidpoints.append(midpoint)
                    
                    for j in 1 ... 5 {
                        
                        let startMidpoint: (lat: Double, long: Double) = findMidpoint(startMidpoints[j-1].long, y1: startMidpoints[j-1].lat, x2: startCoords.longs[i], y2: startCoords.lats[i])
                        let endMidpoint: (lat: Double, long: Double) = findMidpoint(endMidpoints[j-1].long, y1: endMidpoints[j-1].lat, x2: endCoords.longs[i], y2: endCoords.lats[i])
                        startMidpoints.append(startMidpoint)
                        endMidpoints.append(endMidpoint)
                        
                        callYelp(business, places: type, latitude: startMidpoint.lat, longitude: startMidpoint.long, radius: radius, mapView: mapView)
                        callYelp(business, places: type, latitude: endMidpoint.lat, longitude: endMidpoint.long, radius: radius, mapView: mapView)
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

extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        print("Marker Tapped")
        print(marker.icon)
        if marker.icon != GMSMarker.markerImageWithColor(UIColor.blueColor()) {
            performSegueWithIdentifier("Details", sender: self)
        }
        return true
    }
}