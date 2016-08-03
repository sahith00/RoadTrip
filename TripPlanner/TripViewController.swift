//
//  TripViewController.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/8/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import Foundation

class TripViewController: UIViewController {

    var acController: GMSAutocompleteViewController?
    
    @IBOutlet weak var recentSearchesTableView: UITableView!
    
    @IBOutlet weak var startingTextField: UITextField!
    @IBOutlet weak var endingTextField: UITextField!
    
    var acstart: Bool = true
    var tablestart: Bool = true
    
    var cellText: [String] = ["", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadRecentSearches(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        recentSearchesTableView.reloadData()
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
        RealmHelper.addRoute(route)
        loadRecentSearches(tablestart)
    }
    
    @IBAction func startingFieldClicked(sender: AnyObject) {
        print("Start clicked")
        acController = GMSAutocompleteViewController()
        acController!.delegate = self
        acstart = true
        self.presentViewController(acController!, animated: true, completion: nil)
        loadRecentSearches(true)
    }
    
    @IBAction func endingFieldClicked(sender: AnyObject) {
        print("End clicked")
        acController = GMSAutocompleteViewController()
        acController!.delegate = self
        acstart = false
        self.presentViewController(acController!, animated: true, completion: nil)
        loadRecentSearches(false)
    }
    
    func loadRecentSearches(start: Bool) {
        if RealmHelper.retrieveRoutes().count != 0{
            var count = 5
            //print(RealmHelper.retrieveRoutes().count)
            if RealmHelper.retrieveRoutes().count < 5 {
                count = RealmHelper.retrieveRoutes().count
            }
            for i in 0 ..< count {
                if start {
                    cellText[i] = RealmHelper.retrieveRoutes()[RealmHelper.retrieveRoutes().count-i-1].startAddress
                }
                else {
                    cellText[i] = RealmHelper.retrieveRoutes()[RealmHelper.retrieveRoutes().count-i-1].endAddress
                }
            }
        }
        recentSearchesTableView.reloadData()
        tablestart = start
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
        if acstart {
            startingTextField.text = place.formattedAddress
            loadRecentSearches(true)
        }
        else {
            endingTextField.text = place.formattedAddress
            loadRecentSearches(false)
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
        if acstart {
            loadRecentSearches(true)
        }
        else {
            loadRecentSearches(false)
        }
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
        cell.recentSearchLabel.text = cellText[indexPath.row]
        return cell
    }
}

extension TripViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tablestart {
            startingTextField.text = RealmHelper.retrieveRoutes()[RealmHelper.retrieveRoutes().count-indexPath.row-1].startAddress
        }
        else {
            endingTextField.text = RealmHelper.retrieveRoutes()[RealmHelper.retrieveRoutes().count-indexPath.row-1].endAddress
        }
    }
}
