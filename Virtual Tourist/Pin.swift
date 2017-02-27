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

class Pin: NSManagedObject {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Page = "page"
    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var page: Float
    @NSManaged var photos: NSSet
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Get the entity associated with "Pin" type.
        let entity =  NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        // Inherited init method
        super.init(entity: entity,insertInto: context)
        // Init dictionary properties
        latitude = dictionary[Pin.Keys.Latitude] as! NSNumber
        longitude = dictionary[Pin.Keys.Longitude] as! NSNumber
        page = dictionary[Pin.Keys.Page] as! Float
    }
}
