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

    @IBOutlet weak var startingTextField: UITextField!
    @IBOutlet weak var endingTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if startingTextField.text == "" {
            Address.startAddress = "Foster City, CA"
        }
        else {
            Address.startAddress = startingTextField.text!
        }
        if endingTextField.text == "" {
            Address.endAddress = "San Francisco, CA"
        }
        else {
            Address.endAddress = endingTextField.text!
        }
    }
    
    @IBAction func onLaunchClicked(sender: AnyObject) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        self.presentViewController(acController, animated: true, completion: nil)
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

extension TripViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
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
