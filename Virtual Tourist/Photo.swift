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
    
    struct Keys {
        static let ImageID = "imageID"
        static let ImageURL = "imageURL"
    }
    
    // Promote from simple properties to Core Data attributes
    @NSManaged var pin: Pin
    @NSManaged var imageID: String
    @NSManaged var imageURL: String
    @NSManaged var dateAdded: Date
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(pin: Pin, dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Get the entity associated with "Photo" type.
        let entity =  NSEntityDescription.entity(forEntityName: "Photo", in: context)!
        // Inherited init method
        super.init(entity: entity,insertInto: context)
        // Init dictionary properties
        self.pin = pin
        imageID = dictionary[Photo.Keys.ImageID] as! String
        imageURL = dictionary[Photo.Keys.ImageURL] as! String
        dateAdded = Date()
    }
    
    // Cached image
    var locationImage: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imageID)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imageID)
        }
    }
    
    //Delete the associated image file when the Photo managed object is deleted.
    override func prepareForDeletion() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let pathArray = [dirPath, imageID]
        let fileURL = NSURL.fileURL(withPathComponents: pathArray)
        do {
            try FileManager.default.removeItem(at: fileURL!)
        } catch _ {
        }
    }
}
