//
//  RealmHelper.swift
//  TripPlanner
//
//  Created by Sahith Bhamidipati on 7/22/16.
//  Copyright © 2016 Sahith Bhamidipati. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
    
    static func addRoute(route: Route) {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(route)
        }
    }
    
    static func deleteRoute(route: Route) {
        let realm = try! Realm()
        try! realm.write() {
            realm.delete(route)
        }
    }
    
    static func retrieveUniqueRoutes() -> [Route] {
        let routes: Results<Route> = RealmHelper.retrieveRoutes()
        var ans: [Route] = []
        ans.append(routes[0])
        for route in routes {
            for j in 0..<ans.count {
                if route.startAddress == ans[j].startAddress {
                    break
                }
                else {
                    ans.append(route)
                }
            }
        }
        return ans
    }
    
    static func retrieveRoutes() -> Results<Route> {
        let realm = try! Realm()
        let routes = realm.objects(Route)
        return routes
    }
    
    static func retrieveLastRoute() -> Route? {
        let routes = retrieveRoutes()
        if routes.count != 0 {
            let route = routes[routes.count-1]
            return route
        }
        else {
            return nil
        }
    }
}