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


class GasStationViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let apiToContact = "https://maps.googleapis.com/maps/api/directions/json"
        
        Alamofire.request(.GET, apiToContact, parameters: ["origin": Address.startAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "destination": Address.endAddress.stringByReplacingOccurrencesOfString(" ", withString: "+"), "key": "AIzaSyCtJyqEx9hHY11_uU0fUNcTASaFpWy5aWM"])
            .responseJSON { response in
                if let JSON = response.result.value {
                    
                    let count = JSON["routes"]!![0]["legs"]!![0]["steps"]!?.count
                    
                    var index = 0
                    var points: [AnyObject] = []
                    var endCoords: (lats: [Double], longs: [Double]) = ([], [])
                    var startCoords: (lats: [Double], longs: [Double]) = ([], [])
                    
                    while index < count {
                        let routes = JSON["routes"] as! [AnyObject]
                        let route = routes[0]
                        let legs = route["legs"] as! [AnyObject]
                        let leg = legs[0]
                        let steps = leg["steps"] as! [AnyObject]
                        let step = steps[index]
                        let point = step["polyline"]!!["points"]!!
                        let endLat = step["end_location"]!!["lat"]!!
                        let endLong = step["end_location"]!!["lng"]!!
                        let startLat = step["start_location"]!!["lat"]!!
                        let startLong = step["start_location"]!!["lng"]!!
                        endCoords.lats.append(endLat.doubleValue)
                        endCoords.longs.append(endLong.doubleValue)
                        startCoords.lats.append(startLat.doubleValue)
                        startCoords.longs.append(startLong.doubleValue)
                        points.append(point)
                        index+=1
                    }
                    
                    
                    
                    let startCoord: (lat:Double, long:Double) = (startCoords.lats[0], startCoords.longs[0])
                    let endCoord: (lat:Double, long:Double) = (JSON["routes"]!![0]["legs"]!![0]["end_location"]!!["lat"]!!.doubleValue, JSON["routes"]!![0]["legs"]!![0]["end_location"]!!["lng"]!!.doubleValue)
                    
                    let camera = GMSCameraPosition.cameraWithLatitude(startCoord.lat, longitude: startCoord.long, zoom: 8)
                    self.mapView.camera = camera
                    
                    var i = 0
                    let len = endCoords.lats.count
                    while i < len {
                        self.createPath(startCoords.lats[i], startLong: startCoords.longs[i], endLat: endCoords.lats[i], endLong: endCoords.longs[i])
                        i+=1
                    }
                    self.createMarker(startCoord.lat, long: startCoord.long)
                    self.createMarker(endCoord.lat, long: endCoord.long)
                }
        }
        
        YelpClient.sharedInstance.searchWithTerm("") { (gasStations, error) in
            for gasStation in gasStations {
                if let lat = gasStation.lat {
                    if let long = gasStation.long {
                        self.createMarker(lat, long: long)
                    }
                }
            }
        }
    }
    
    func createMarker(lat: Double, long: Double) {
        let marker = GMSMarker()
        let geocoder = GMSGeocoder()
        marker.position = CLLocationCoordinate2DMake(lat, long)
        geocoder.reverseGeocodeCoordinate(marker.position) { (response, error) in
            marker.title = response?.firstResult()?.locality
            marker.snippet = response?.firstResult()?.country
        }
        marker.map = self.mapView
    }
    
    func createPath(startLat: Double, startLong: Double, endLat: Double, endLong: Double) {
        let path = GMSMutablePath()
        path.addLatitude(startLat, longitude: startLong)
        path.addLatitude(endLat, longitude: endLong)
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.redColor()
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView
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
    
    
//    @IBAction func pickPlace(sender: UIBarButtonItem) {
//        let center = CLLocationCoordinate2DMake(51.5108396, -0.0922251)
//        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
//        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
//        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
//        let config = GMSPlacePickerConfig(viewport: viewport)
//        let placePicker = GMSPlacePicker(config: config)
//        
//        placePicker.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//            
//            if let place = place {
//                print("Place name \(place.name)")
//                print("Place address \(place.formattedAddress)")
//                print("Place attributions \(place.attributions)")
//            } else {
//                print("No place selected")
//            }
//        })
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
