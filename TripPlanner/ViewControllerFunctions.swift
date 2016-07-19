//
//  ViewControllerFunctions.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/19/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import Foundation
import GoogleMaps

class ViewControllerFunctions: UIViewController {
    
    func createMarker(title: String, lat: Double, long: Double, mapView: GMSMapView) {
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
        marker.map = mapView
    }
    
    func createPath(route: String, mapView: GMSMapView) {
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 1.0
        polyline.map = mapView
    }
    
    func addDirections(json: [NSObject : AnyObject], mapView: GMSMapView) {
        let routes: [NSObject : AnyObject] = (json["routes"]![0] as! [NSObject : AnyObject])
        let route: [NSObject : AnyObject] = (routes["overview_polyline"] as! [NSObject : AnyObject])
        let overview_route: String = (route["points"] as! String)
        createPath(overview_route, mapView: mapView)
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

}