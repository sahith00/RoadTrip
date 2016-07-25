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
    
    static func addAddress(address: Address) {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(address)
        }
    }
    
    static func deleteAddress(address: Address) {
        let realm = try! Realm()
        try! realm.write() {
            realm.delete(address)
        }
    }
    
    /*static func updateAddress(oldAddress: Address, newAddress: Address) {
        let realm = try! Realm()
        try! realm.write(
            oldAddress.startAddress = newAddress.startAddress
            oldAddress.endAddress = newAddress.endAddress
        )
    }*/
    
    static func retrieveAddresses() -> Results<Address> {
        let realm = try! Realm()
        let addresses = realm.objects(Address)
        return addresses
    }
    
    static func retrieveLastAddress() -> Address {
        let addresses = retrieveAddresses()
        let address = addresses[addresses.count-1] //  addresses.last! // 
        return address
    }
}