//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

// MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
// MARK: - Variables
    var selectedPin: Pin!
    var annotationToBeAdded: Annotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Long press gesture
        self.defineLongPressGesture()
        
        // Retrieve persisted map region and span data
        self.getMapData()
        
        do {
            // Fetched Results Controller
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        displayFetchedPins()
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController<Pin> = {
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        }()
}

// MARK: - Map View Delegate
extension MapViewController: MKMapViewDelegate {
    
    // Saves map's region when changed.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapRegionCenterLatitude: CLLocationDegrees = mapView.region.center.latitude
        let mapRegionCenterLongitude: CLLocationDegrees = mapView.region.center.longitude
        let mapRegionSpanLatitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
        let mapRegionSpanLongitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta
        
        var mapDictionary: [String: CLLocationDegrees] = [String: CLLocationDegrees]()
        mapDictionary.updateValue(mapRegionCenterLatitude, forKey: "centerLatitude")
        mapDictionary.updateValue(mapRegionCenterLongitude, forKey: "centerLongitude")
        mapDictionary.updateValue(mapRegionSpanLatitudeDelta, forKey: "spanLatitudeDelta")
        mapDictionary.updateValue(mapRegionSpanLongitudeDelta, forKey: "spanLongitudeDelta")
        
        UserDefaults.standard.set(mapDictionary, forKey: "mapInfo")
    }
    
    // Create annotation.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is Annotation {
        
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                pinView!.pinColor = .green
                pinView!.animatesDrop = true
                pinView!.canShowCallout = false
            } else {
                pinView!.annotation = annotation
            }
            return pinView
        }
        return nil
    }
    
    // Actions for selecting annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? Annotation {
            mapView.deselectAnnotation(annotation, animated: true)
            
            let pinLat = view.annotation!.coordinate.latitude
            let pinLon = view.annotation!.coordinate.longitude
            
            selectedPin = searchForPinInCoreData(pinLat, longitude: pinLon)
            
            // Segue to PhotoViewController
            performSegue(withIdentifier: "ShowPhotos", sender: selectedPin)
        }
    }
}

// MARK: - Gesture Recognizer Delegate
extension MapViewController: UIGestureRecognizerDelegate {
    
    // Adds pin annotation to map when long press gesture is used
    func defineLongPressGesture() {
        let gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        gesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(gesture)
    }
}

// MARK: - Fetched Results Controller Delegate
extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {   }
}

// MARK: - Additional Methods
extension MapViewController {
    
    // Add pin annotation to map using long press gesture
    func addAnnotation(_ longPress: UIGestureRecognizer) {
        let touchPoint = longPress.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        switch longPress.state {
        // Long press gesture begins
        case .began:
            annotationToBeAdded = Annotation()
            annotationToBeAdded!.setCoordinate(newCoordinates)
            mapView.addAnnotation(annotationToBeAdded!)
            
            // Fetch images from Flickr when pin is dropped
            let pin = pinFromAnnotation(annotationToBeAdded!)
            getImagesFromCoordinates(pin)
        
        // Pin is being dragged
        case .changed:
            // Update pin coordinates
            annotationToBeAdded!.setCoordinate(newCoordinates)
        
        // Long press gesture is released
        case .ended:
            // Update pin coordinates
            annotationToBeAdded!.setCoordinate(newCoordinates)
            
            // Save to Core Data
            DispatchQueue.main.async {
                CoreDataStackManager.sharedInstance().saveContext()
                
                do {
                    // Add pin to fetched objects
                    try self.fetchedResultsController.performFetch()
                } catch _ {
                }
            }
            
        default:
            return
        }
    }
    
    // Retrieve persisted map region and span
    func getMapData() {
        if let mapInfo: [String : CLLocationDegrees] = UserDefaults.standard.dictionary(forKey: "mapInfo") as? [String : CLLocationDegrees] {
            let mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: mapInfo["centerLatitude"]!,
                    longitude: mapInfo["centerLongitude"]!
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: (mapInfo["spanLatitudeDelta"]!),
                    longitudeDelta: (mapInfo["spanLongitudeDelta"]!)
                )
            )
            mapView.region = mapRegion
        } else {
            print("Map info unavailable.")
        }
    }
    
    // Creates a Pin object
    func pinFromAnnotation(_ annotation: MKAnnotation) -> Pin {
        let pageLimit = 20
        let randomPage = Float(arc4random_uniform(UInt32(pageLimit))) + 1
        
        let dictionary = [
            Pin.Keys.Latitude: annotation.coordinate.latitude as NSNumber,
            Pin.Keys.Longitude: annotation.coordinate.longitude as NSNumber,
            Pin.Keys.Page: randomPage
        ] as [String : Any]
        return Pin(dictionary: dictionary as [String : AnyObject], context: sharedContext)
    }
    
    // Adds pins fetched from Core Data to map view.
    func displayFetchedPins() {
        if let pins = fetchedResultsController.fetchedObjects as [Pin]! {
            for pin in pins {
                let annotationToBeAdded = Annotation()
                let pinLocation = CLLocationCoordinate2D(latitude: Double(pin.latitude), longitude: Double(pin.longitude))
                annotationToBeAdded.setCoordinate(pinLocation)
                mapView.addAnnotation(annotationToBeAdded)
            }
        }
    }
    
    // Support for finding selected pin in Core Data
    func searchForPinInCoreData(_ latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Pin {
        let pins = fetchedResultsController.fetchedObjects as [Pin]!
        let lat = latitude as NSNumber
        let lon = longitude as NSNumber
        
        return pins!.filter { pin in
            pin.latitude == lat && pin.longitude == lon
            }.first!
    }
    
    // Fetch images from Flickr using pin coordinates
    func getImagesFromCoordinates(_ pin: Pin) {
        FlickrClient.sharedInstance().getFlickrPhotos(pin.latitude as Double, longitude: pin.longitude as Double, page: pin.page) { photosArray, error in
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
    
    // Prepare for segue to Photo View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos" {
            let photoVC = segue.destination as!
            PhotoViewController
            photoVC.selectedPin = selectedPin
        }
    }

}

