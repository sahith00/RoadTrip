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
        let startCoord: (lat:Double, long:Double) = (15.866, 76.201)
        let endCoord: (lat:Double, long:Double) = (16.823, 78.954)
        
        let camera = GMSCameraPosition.cameraWithLatitude(15.866, longitude: 77.201, zoom: 6)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        //mapView.myLocationEnabled = true
        
        
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
        
        let apiToContact = "https://maps.googleapis.com/maps/api/directions/json"
        
        Alamofire.request(.GET, apiToContact, parameters: ["origin": "Bengaluru,+India", "destination": "Andhra+Pradesh,+India", "key": "AIzaSyCtJyqEx9hHY11_uU0fUNcTASaFpWy5aWM"])
            .responseJSON { response in
                 if let JSON = response.result.value {
                    JSON["routes"]!![0]["legs"]!![0]["steps"]!!
  //                      print(json["polyline"]!!["points"]!!)
                   
               }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTripViewController(segue: UIStoryboardSegue) {
        
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
    }
    
    
    // This code will call the iTunes top 25 movies endpoint listed abov
    
    
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
