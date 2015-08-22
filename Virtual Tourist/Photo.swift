//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/16/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import CoreData

// Make Photo available to Objective-C code
@objc(Photo)

class Photo: NSManagedObject {
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var pin: Pin?
    @NSManaged var photoURL: String?
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(photoURL: String, context: NSManagedObjectContext) {
        // Get the entity associated with "Photo" type.
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        // Init dictionary properties
        self.photoURL = photoURL
    }
}
