//
//  HotelViewController.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/8/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class HotelViewController: UIViewController {

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
                    self.createMarkers(startCoord.lat, startLong: startCoord.long, endLat: endCoord.lat, endLong: endCoord.long)
                }
        }
    }
    
    func createMarkers(startLat: Double, startLong: Double, endLat: Double, endLong: Double) {
        let marker = GMSMarker()
        let geocoder = GMSGeocoder()
        marker.position = CLLocationCoordinate2DMake(startLat, startLong)
        geocoder.reverseGeocodeCoordinate(marker.position) { (response, error) in
            marker.title = response?.firstResult()?.locality
            marker.snippet = response?.firstResult()?.country
        }
        marker.map = self.mapView
        
        let marker2 = GMSMarker()
        let geocoder2 = GMSGeocoder()
        marker2.position = CLLocationCoordinate2DMake(endLat, endLong)
        marker2.map = self.mapView
        geocoder2.reverseGeocodeCoordinate(marker2.position) { (response, error) in
            marker2.title = response?.firstResult()?.locality
            marker2.snippet = response?.firstResult()?.country
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
