//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/16/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// Make Pin available to Objective-C code
@objc(Pin)

class Pin: NSManagedObject, Hashable {
    
//    // Hashvalue to get PhotoViewController with correct pin's coordinates.
//    override var hashValue: Int {
//        get {
//            return "\(latitude.hashValue),\(longitude.hashValue)".hashValue
//        }
//    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(location: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        // Get the entity associated with "Pin" type.
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        // Init dictionary properties
        latitude = location.latitude as Double
        longitude = location.longitude as Double
    }
}

func == (lhs: Pin, rhs: Pin) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
