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
    
    @IBOutlet weak var recentSearchesTableView: UITableView!
    
    @IBOutlet weak var startingTextField: UITextField!
    @IBOutlet weak var endingTextField: UITextField!
    
    var start: Bool = true
    
    var num: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        recentSearchesTableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        num+=1
    }
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let route: Route = Route()

        if startingTextField.text == "" {
            if let lastRoute = RealmHelper.retrieveLastRoute() {
                route.startAddress = lastRoute.startAddress
            }
            else {
                route.startAddress = "Foster City, CA"
            }
        }
        else {
            route.startAddress = startingTextField.text!
        }
        if endingTextField.text == "" {
            if let lastRoute = RealmHelper.retrieveLastRoute() {
                route.endAddress = lastRoute.endAddress
            }
            else {
                route.endAddress = "San Francisco, CA"
            }
        }
        else {
            route.endAddress = endingTextField.text!
        }
        print(route.startAddress)
        print(route.endAddress)
        RealmHelper.addRoute(route)
        
        //print(RealmHelper.retrieveRoutes())
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

extension TripViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if RealmHelper.retrieveRoutes().count > 5 {
            return 5
        }
        else {
            return RealmHelper.retrieveRoutes().count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecentSearchCell") as! RecentSearchesTableViewCell
        cell.recentSearchLabel.text = RealmHelper.retrieveUniqueRoutes()[RealmHelper.retrieveUniqueRoutes().count-indexPath.row-1].startAddress ?? "Foster City, CA"
        print(RealmHelper.retrieveRoutes()[RealmHelper.retrieveRoutes().count-indexPath.row-1].startAddress)
        return cell
    }
}

extension TripViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        startingTextField.text = RealmHelper.retrieveRoutes()[RealmHelper.retrieveRoutes().count-indexPath.row-num].startAddress
        print(RealmHelper.retrieveRoutes().count-indexPath.row-num)
        print(num)
        print(RealmHelper.retrieveRoutes())
    }
}
