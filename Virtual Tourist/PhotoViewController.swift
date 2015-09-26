//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
// MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    
// MARK: - Variables
    var selectedPin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noPhotosLabel.hidden = true
        
        // Collection view delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self

        // Fetched Results Controller
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Sets map region and span
        self.setLocation()
        
        self.collectionView.reloadData()
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            noPhotosLabel.hidden = false
        }
        
//        if selectedPin.photos.isEmpty {
//        // TODO: - Retrieve Flickr images with taskForResource method.
//        }
    }
    
// MARK: - Collection View Methods
    
    // Number of Collection View cells
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionItems = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionItems.numberOfObjects
    }
    
    // Collection View cell information
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Assigns custom cell.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! CollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // Displays placeholder or downloaded image
        assignCellImage(cell, photo: photo)
        
        return cell
    }
        
    // Deletes photo when selected
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Define selected photo
        let selectedPhoto = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // Remove photo from Documents Directory
        selectedPhoto.locationImage = nil
        
        // Delete from Core Data and save
        sharedContext.deleteObject(selectedPhoto)
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Reload collection view data
        collectionView.reloadData()
    }
    
// MARK: - Additional Methods
    
    // Sets map region and span using selected pin from MapViewController
    func setLocation() {
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(latitude: Double(selectedPin!.latitude), longitude: Double(selectedPin!.longitude))
        let region = MKCoordinateRegion(center: location, span: span)
        annotation.coordinate = location
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    // Sets cell image to placeholder or downloaded image
    func assignCellImage(cell: CollectionViewCell, photo: Photo) {
        cell.activityView.startAnimating()
        
        if photo.locationImage == nil {
            cell.photoView.image = UIImage(named: "NoImage")
        } else {
            cell.photoView.image = photo.locationImage
            cell.activityView.stopAnimating()
            cell.activityView.hidden = true
        }

    }
    
// MARK: - Core Data Convenience
    
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.selectedPin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()


}
