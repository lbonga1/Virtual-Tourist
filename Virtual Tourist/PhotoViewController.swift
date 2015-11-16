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

class PhotoViewController: UIViewController {
    
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

        do {
            // Fetched Results Controller
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Sets map region and span
        self.setLocation()
        
        self.collectionView.reloadData()
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            noPhotosLabel.hidden = false
        }
    }
    
// MARK: - Actions
    
    // Action to download a new set of photos from Flickr
    @IBAction func getNewCollection(sender: AnyObject) {
        // Deletes currently downloaded collection of photos
        self.deleteCurrentCollection()
        
        // Sets the pin's page to a random page
        let pageLimit = 20
        let randomPage = Float(arc4random_uniform(UInt32(pageLimit))) + 1
        selectedPin.page = randomPage
        
        // Starts new download from Flickr
        self.newFlickrCollection(selectedPin)
    }
    
// MARK: - Core Data Convenience
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
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

// MARK: - Collection View Data Source
extension PhotoViewController: UICollectionViewDataSource {
    
    // Number of Collection View cells
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionItems = fetchedResultsController.sections![section] 
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
}

// MARK: - Collection View Delegate
extension PhotoViewController: UICollectionViewDelegate {
        
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
}
    
// MARK: - Fetched Results Controller Delegate
extension PhotoViewController: NSFetchedResultsControllerDelegate {
        
    func controllerDidChangeContent(controller: NSFetchedResultsController) {   }
}

// MARK: - Additional Methods
extension PhotoViewController {
    
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
    
    // Fetch images from Flickr using pin coordinates
    func newFlickrCollection(pin: Pin) {
        FlickrClient.sharedInstance().getFlickrPhotos(selectedPin.latitude as Double, longitude: selectedPin.longitude as Double, page: selectedPin.page) { photosArray, error in
            if let error = error {
                print("error code: \(error.code)")
                print("error description: \(error.localizedDescription)")
            } else {
                if let photosArray = photosArray as? [[String : AnyObject]] {
                    if photosArray.count == 0 {
                        dispatch_async(dispatch_get_main_queue()) {
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                        return
                    }
                    photosArray.map { (photoDictionary: [String : AnyObject]) -> Photo in
                        var dictionary = [String : String]()
                        
                        if let imageURL = photoDictionary[FlickrClient.JsonResponseKeys.ImagePath] as? String {
                            if let imageID = photoDictionary[FlickrClient.JsonResponseKeys.ImageID] as? String {
                                dictionary[Photo.Keys.ImageID] = imageID
                                dictionary[Photo.Keys.ImageURL] = imageURL
                            }
                        }
                        // Init the Photo object
                        let photo = Photo(pin: pin, dictionary: dictionary, context: self.sharedContext)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            photo.pin = pin
                        }
                        
                        // Get that image on a background thread
                        let session = FlickrClient.sharedInstance().session
                        let url = NSURL(string: photo.imageURL)!
                        
                        let task = session.dataTaskWithURL(url) { data, response, error in
                            if let error = error {
                                // handle error
                            }
                            else {
                                let image = UIImage(data: data!)
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    photo.locationImage = image
                                    CoreDataStackManager.sharedInstance().saveContext()
                                }
                            }
                        }
                        task.resume()
                        
                        return photo
                    }
                }
            }
        }
    }
    
    // Delete current collection of downloaded photos
    func deleteCurrentCollection() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            // Remove from documents directory
            photo.locationImage = nil
            // Remove reference from core data and save
            self.sharedContext.deleteObject(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        // Refresh collection view data
        collectionView.reloadData()
    }
}
