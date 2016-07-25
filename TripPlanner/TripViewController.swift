//
//  TripViewController.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/8/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import UIKit
import GoogleMaps

class TripViewController: UIViewController {
    
    var acController: GMSAutocompleteViewController?
    
    @IBOutlet weak var startingTextField: UITextField!
    @IBOutlet weak var endingTextField: UITextField!
    
//    var address: Address = Address()
    
    var start: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let address: Address = Address()

        if startingTextField.text == "" {
            address.startAddress = "Foster City, CA"
        }
        else {
            address.startAddress = startingTextField.text!
        }
        if endingTextField.text == "" {
            address.endAddress = "San Francisco, CA"
        }
        else {
            address.endAddress = endingTextField.text!
        }
        print(address.startAddress)
        print(address.endAddress)
        RealmHelper.addAddress(address)
        
        print(RealmHelper.retrieveAddresses())
    }
    
    @IBAction func startingAddressClicked(sender: AnyObject) {
        acController = GMSAutocompleteViewController()
        acController!.delegate = self
        start = true
        self.presentViewController(acController!, animated: true, completion: nil)
    }

    @IBAction func endingAddressClicked(sender: AnyObject) {
        acController = GMSAutocompleteViewController()
        acController!.delegate = self
        start = false
        self.presentViewController(acController!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation


}

extension TripViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        if start {
            startingTextField.text = place.formattedAddress
        }
        else {
            endingTextField.text = place.formattedAddress
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: \(error.description)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
