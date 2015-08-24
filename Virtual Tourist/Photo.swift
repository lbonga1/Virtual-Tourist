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
    
//    struct Keys {
//        static let imagePath = "image_path"
//    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var pin: Pin?
    @NSManaged var imagePath: String
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imagePath: String, context: NSManagedObjectContext) {
        // Get the entity associated with "Photo" type.
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
//        // Init dictionary properties
//        imagePath = dictionary[Keys.imagePath] as! String
    }
}
