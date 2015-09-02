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
    @NSManaged var imagePath: String
    @NSManaged var imageURL: String
    
    // Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: Pin, dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Get the entity associated with "Photo" type.
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        // Inherited init method
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        // Init dictionary properties
        self.pin = pin
        var farm = dictionary["farm"] as! Int
        var server = dictionary["server"] as! String
        var id = dictionary["id"] as! String
        var secret = dictionary["secret"] as! String
        var url = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        self.imagePath = url.lastPathComponent
        self.imageURL = url
        
//        imagePath = dictionary["image_path"] as! String
//        imageURL = dictionary["image_url"] as! String
    }
    
    // Cached image
    var locationImage: UIImage? {
        
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
        }
    }
    
    //Delete the associated image file when the Photo managed object is deleted.
    override func prepareForDeletion() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let pathArray = [dirPath, imagePath]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
        NSFileManager.defaultManager().removeItemAtURL(fileURL, error: nil)
        
    }

}
