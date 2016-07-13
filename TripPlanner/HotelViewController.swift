//
//  HotelViewController.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/8/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import UIKit
import GoogleMaps

class HotelViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startCoord: (lat:Double, long:Double) = (15.866, 76.201)
        let endCoord: (lat:Double, long:Double) = (16.823, 78.954)
        
        let camera = GMSCameraPosition.cameraWithLatitude(15.866, longitude: 77.201, zoom: 6)
        mapView.camera = camera
        
        
        let marker = GMSMarker()
        let geocoder = GMSGeocoder()
        marker.position = CLLocationCoordinate2DMake(startCoord.lat, startCoord.long)
        geocoder.reverseGeocodeCoordinate(marker.position) { (response, error) in
            marker.title = response?.firstResult()?.locality
            marker.snippet = response?.firstResult()?.country
        }
        marker.map = mapView
        
        let marker2 = GMSMarker()
        let geocoder2 = GMSGeocoder()
        marker2.position = CLLocationCoordinate2DMake(endCoord.lat, endCoord.long)
        marker2.map = mapView
        geocoder2.reverseGeocodeCoordinate(marker2.position) { (response, error) in
            marker2.title = response?.firstResult()?.locality
            marker2.snippet = response?.firstResult()?.country
        }
        
        let marker3 = GMSMarker()
        marker3.map = mapView
        let geocoder3: CLGeocoder = CLGeocoder()
        geocoder3.geocodeAddressString("Bengaluru, India") { (placemarks, error) in
            for aPlacemark: CLPlacemark in placemarks! {
                // Process the placemark.
                marker3.position = CLLocationCoordinate2D(latitude: aPlacemark.location!.coordinate.latitude, longitude: aPlacemark.location!.coordinate.longitude)
            }
        }
        
        let path = GMSMutablePath()
        path.addLatitude(startCoord.lat, longitude: startCoord.long)
        path.addLatitude(endCoord.lat, longitude: endCoord.long)
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.redColor()
        polyline.strokeWidth = 5.0
        polyline.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTripViewControllerFromHotelViewController(segue: UIStoryboardSegue) {
        
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
