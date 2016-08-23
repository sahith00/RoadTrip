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
    
    var details: Details = Details()
    var urls: [GMSMarker: NSURL] = [:]
    
    func createMarker(isDestinationMarker: Bool, title: String, url: NSURL?, rating: Double?, lat: Double, long: Double, mapView: GMSMapView){
        let marker = GMSMarker()
        let geocoder = GMSGeocoder()
        marker.position = CLLocationCoordinate2DMake(lat, long)
        if isDestinationMarker {
            marker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            marker.map = mapView
        }
        geocoder.reverseGeocodeCoordinate(marker.position) { (response, error) in
            marker.title = title
            
            if let rating = rating {
                marker.snippet = "Rating: "+String(rating)+"/5"
            }
            else {
                marker.snippet = response?.firstResult()?.locality
            }
        }
        if let rating = rating {
            if rating >= 3.0 {
                marker.map = mapView
            }
        }
        if let url = url {
            urls[marker] = url
        }
    }
    
    func createPath(route: String, mapView: GMSMapView) {
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 5.0
        polyline.map = mapView
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
    
    func findAverage(arr: [Double]) -> Double{
        var sum: Double = 0
        for i in 0..<arr.count {
            sum += arr[i]
        }
        return(sum/Double(arr.count))
    }
    
    func callYelp(business: String, places: (names: [String], lats: [Double], longs: [Double]), latitude: Double, longitude: Double, radius: Double, mapView: GMSMapView){
        YelpClient.sharedInstance.searchWithTerm(business, lat: latitude, long: longitude, radius: radius, completion: { (businesses, error) in
            if businesses != nil {
                for business in businesses {
                    if let lat = business.lat {
                        if let long = business.long {
                            self.createMarker(false, title: business.name!, url: business.mobileURL!, rating: business.rating, lat: lat, long: long, mapView: mapView)
                        }
                    }
                }
            }
        })
    }
}