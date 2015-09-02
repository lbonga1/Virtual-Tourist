//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit

class PhotoViewController: UIViewController {
    
// MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
// MARK: - Variables
    
    var selectedPin: Pin?
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.collectionView.reloadData()
        
        if photos.isEmpty {
        // TODO: - Retrieve Flickr images with taskForResource method.
        }
    }
    
// MARK: - Collection View Methods
    
    // Number of Collection View cells
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // Collection View cell information
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Assigns custom cell.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! CollectionViewCell
        let photo = photos[indexPath.item]
        
        if photo.locationImage != nil {
            cell.photoView.image = photo.locationImage
        } else {
            cell.photoView.image = UIImage(named: "NoImage")
            cell.activityView.hidden = false
            cell.activityView.startAnimating()
            dispatch_async(dispatch_get_main_queue()) {
                //get image
                let imageURL = NSURL(string: photo.imageURL)
                let imageData = NSData(contentsOfURL: imageURL!)
                let image = UIImage(data: imageData!)
                
                cell.activityView.stopAnimating()
                cell.activityView.hidden = true
                cell.photoView.image = image
                photo.locationImage = image
                
                // save in core data
                var error:NSError? = nil
                //self.saveContext()(&error)
                
                if let error = error {
                    println("error saving context: \(error.localizedDescription)")
                    // TODO: -Add UI alert message
                }
            }
        }
        return cell
    }

    // Allows for editing Collection View cells.
    func collectionView(collectionView: UICollectionView, canEditItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
        
    // Changes cell opacity and updates delete button title when deselected.
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.alpha = 1.0
        //updateDeleteButtonTitle()
    }
    
// MARK: - Core Data Convenience
    
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }

}
