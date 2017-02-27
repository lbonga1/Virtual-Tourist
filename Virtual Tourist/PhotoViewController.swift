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
        
        noPhotosLabel.isHidden = true
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        // Sets map region and span
        self.setLocation()
        
        self.collectionView.reloadData()
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            noPhotosLabel.isHidden = false
        }
    }
    
// MARK: - Actions
    
    // Action to download a new set of photos from Flickr
    @IBAction func getNewCollection(_ sender: AnyObject) {
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
    lazy var fetchedResultsController: NSFetchedResultsController<Photo> = {
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionItems = fetchedResultsController.sections![section] 
        return sectionItems.numberOfObjects
    }
    
    // Collection View cell information
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Assigns custom cell.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! CollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath) 
        
        // Displays placeholder or downloaded image
        assignCellImage(cell, photo: photo)
        
        return cell
    }
}

// MARK: - Collection View Delegate
extension PhotoViewController: UICollectionViewDelegate {
        
    // Deletes photo when selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselct item to make it re-selectable
        collectionView.deselectItem(at: indexPath, animated: true)
        // Display delete confirmation alert
        self.displayAlert(indexPath)
    }
}
    
// MARK: - Fetched Results Controller Delegate
extension PhotoViewController: NSFetchedResultsControllerDelegate {
        
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {   }
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
    func assignCellImage(_ cell: CollectionViewCell, photo: Photo) {
        cell.activityView.startAnimating()
        
        if photo.locationImage == nil {
            cell.photoView.image = UIImage(named: "NoImage")
        } else {
            cell.photoView.image = photo.locationImage
            cell.activityView.stopAnimating()
            cell.activityView.isHidden = true
        }
    }
    
    // Fetch images from Flickr using pin coordinates
    func newFlickrCollection(_ pin: Pin) {
        FlickrClient.sharedInstance().getFlickrPhotos(selectedPin.latitude as Double, longitude: selectedPin.longitude as Double, page: selectedPin.page) { photosArray, error in
            if let error = error {
                print("error code: \(error.code)")
                print("error description: \(error.localizedDescription)")
            } else {
                if let photosArray = photosArray as? [[String : AnyObject]] {
                    if photosArray.count == 0 {
                        DispatchQueue.main.async {
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
                        let photo = Photo(pin: pin, dictionary: dictionary as [String : AnyObject], context: self.sharedContext)
                        
                        DispatchQueue.main.async {
                            photo.pin = pin
                        }
                        
                        // Get that image on a background thread
                        let session = FlickrClient.sharedInstance().session
                        let url = URL(string: photo.imageURL)!
                        
                        let task = session.dataTask(with: url, completionHandler: { data, response, error in
                            if let error = error {

                                print("error description: \(error.localizedDescription)")
                            
                            }
                            else {
                                let image = UIImage(data: data!)
                                
                                DispatchQueue.main.async {
                                    photo.locationImage = image
                                    CoreDataStackManager.sharedInstance().saveContext()
                                    
                                    self.collectionView.reloadData()
                                }
                            }
                        }) 
                        task.resume()
                        
                        return photo
                    }
                }
            }
        }
    }
    
    // Delete current collection of downloaded photos
    func deleteCurrentCollection() {
        for photo in fetchedResultsController.fetchedObjects as [Photo]! {
            // Remove from documents directory
            photo.locationImage = nil
            // Remove reference from core data and save
            self.sharedContext.delete(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    // Support for deleting a single photo
    func deleteSinglePhoto(_ indexPath: IndexPath) {
        // Define selected photo
        let selectedPhoto = fetchedResultsController.object(at: indexPath) 
        
        // Remove photo from Documents Directory
        selectedPhoto.locationImage = nil
        
        // Delete from Core Data and save
        sharedContext.delete(selectedPhoto)
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Reload collection view data
        collectionView.reloadData()
    }
    
    // Displays confirmation alert for deleting a photo.
    func displayAlert(_ indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you want to permanently delete this photo?", preferredStyle: .alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.default, handler: { (alertController) -> Void in
            self.deleteSinglePhoto(indexPath)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
