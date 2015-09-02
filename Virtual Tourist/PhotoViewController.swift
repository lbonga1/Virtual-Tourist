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
        // Sets map region and span
        self.setLocation()
        
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
        
        // Sets cell's image to cached photo if available
        if photo.locationImage != nil {
            cell.photoView.image = photo.locationImage
        } else {
            // Sets cell's image to placeholder while retrieving photo
            cell.photoView.image = UIImage(named: "NoImage")
            cell.activityView.hidden = false
            cell.activityView.startAnimating()
            dispatch_async(dispatch_get_main_queue()) {
                // Get image
                let imageURL = NSURL(string: photo.imageURL)
                let imageData = NSData(contentsOfURL: imageURL!)
                let image = UIImage(data: imageData!)
                
                // Sets cell's image to retrieved photo and stores in cache
                cell.activityView.stopAnimating()
                cell.activityView.hidden = true
                cell.photoView.image = image
                photo.locationImage = image
                
                // Save in Core Data
                var error:NSError? = nil
                self.sharedContext.save(&error)
                
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
// MARK: - Additional Methods
    
    // Sets map region and span using selected pin from MapViewController
    func setLocation() {
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(latitude: Double(selectedPin!.latitude), longitude: Double(selectedPin!.longitude))
        let region = MKCoordinateRegion(center: location, span: span)
        annotation.coordinate = location
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
// MARK: - Core Data Convenience
    
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }

}
