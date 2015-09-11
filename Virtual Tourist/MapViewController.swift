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

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

// MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
// MARK: - Variables
    var selectedPin: Pin!
    var annotationToBeAdded: Annotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Long press gesture
        var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        gesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(gesture)
        
        // Retrieve persisted map region and span data
        self.getMapData()
        
        // Fetched Results Controller
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        displayFetchedPins()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
    }

// MARK: - MKMapViewDelegate
    
    // Saves map's region when changed.
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        let mapRegionCenterLatitude: CLLocationDegrees = mapView.region.center.latitude
        let mapRegionCenterLongitude: CLLocationDegrees = mapView.region.center.longitude
        let mapRegionSpanLatitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
        let mapRegionSpanLongitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta
        
        var mapDictionary: [String: CLLocationDegrees] = [String: CLLocationDegrees]()
        mapDictionary.updateValue(mapRegionCenterLatitude, forKey: "centerLatitude")
        mapDictionary.updateValue(mapRegionCenterLongitude, forKey: "centerLongitude")
        mapDictionary.updateValue(mapRegionSpanLatitudeDelta, forKey: "spanLatitudeDelta")
        mapDictionary.updateValue(mapRegionSpanLongitudeDelta, forKey: "spanLongitudeDelta")
        
        NSUserDefaults.standardUserDefaults().setObject(mapDictionary, forKey: "mapInfo")
    }
    
    // Create annotation.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is Annotation {
        
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                pinView!.pinColor = .Green
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
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let annotation = view.annotation as? Annotation {
            mapView.deselectAnnotation(view.annotation, animated: true)
            println("pin tapped")
            
            let pinLat = view.annotation.coordinate.latitude
            let pinLon = view.annotation.coordinate.longitude
            
            selectedPin = searchForPinInCoreData(pinLat, longitude: pinLon)
            
            performSegueWithIdentifier("ShowPhotos", sender: selectedPin)
        }
    }
    
// MARK: - Additional Methods
    
    func addAnnotation(longPress: UIGestureRecognizer) {
        var touchPoint = longPress.locationInView(mapView)
        var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        switch longPress.state {
        case .Began:
            annotationToBeAdded = Annotation()
            annotationToBeAdded!.setCoordinate(newCoordinates)
            mapView.addAnnotation(annotationToBeAdded)
            
            //let pin = Pin(location: newCoordinates, context: self.sharedContext)
            let pin = pinFromAnnotation(annotationToBeAdded!)
            let parameters :[String:AnyObject] = ["lat":"\(pin.latitude)", "lon":"\(pin.longitude)"]
            
            // Pre-fetch images from Flickr
            FlickrClient.sharedInstance().taskForResource(parameters) { [unowned self] jsonResult, error in
                
                // Handle the error case
                if let error = error {
                    println("Error searching for photos: \(error.localizedDescription)")
                    return
                }
                
                // Get a Swift dictionary from the JSON data
                if let photosDictionary = jsonResult.valueForKey("photos") as? [String : AnyObject] {
//                    // Get total pages
//                    if let maxPages = photosDictionary["pages"] as? NSNumber {
//                        pin.pages = maxPages
//                    }
//                    // Get current page number
//                    if let pageNumber = photosDictionary["page"] as? NSNumber {
//                        pin.page = pageNumber
//                    }
                    if let photoDictionary = photosDictionary["photo"] as? [[String : AnyObject]] {
                        // Build Photo array
                        var photos = photoDictionary.map() {
                            Photo(pin: pin, dictionary: $0, context: self.sharedContext)
                        }
                        var error:NSError? = nil
                        
                        // Save to Core Data
                        self.sharedContext.save(&error)
                        
                        if let error = error {
                            // TODO: Display UI Alert
                            println("error saving context: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
        case .Changed:
            annotationToBeAdded!.setCoordinate(newCoordinates)
            
        case .Ended:
            annotationToBeAdded!.setCoordinate(newCoordinates)
            
            // Save to Core Data
            self.saveContext()
            
        default:
            return
        }
    }
    
    // Retrieve persisted map region and span
    func getMapData() {
        if let mapInfo: [String : CLLocationDegrees] = NSUserDefaults.standardUserDefaults().dictionaryForKey("mapInfo") as? [String : CLLocationDegrees] {
            var mapRegion = MKCoordinateRegion(
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
            println("Map info unavailable.")
        }
    }
    
    func pinFromAnnotation(annotation: MKAnnotation) -> Pin {
        let dictionary = [
            Pin.Keys.Latitude: annotation.coordinate.latitude as NSNumber,
            Pin.Keys.Longitude: annotation.coordinate.longitude as NSNumber,
        ]
        return Pin(dictionary: dictionary, context: sharedContext)
    }
    
    func displayFetchedPins() {
        if let pins = fetchedResultsController.fetchedObjects as? [Pin] {
            for pin in pins {
                let annotationToBeAdded = Annotation()
                let pinLocation = CLLocationCoordinate2D(latitude: Double(pin.latitude), longitude: Double(pin.longitude))
                annotationToBeAdded.setCoordinate(pinLocation)
                mapView.addAnnotation(annotationToBeAdded)
            }
        }
    }
    
    // Support for finding selected pin in Core Data
    func searchForPinInCoreData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Pin {
        let pins = fetchedResultsController.fetchedObjects as! [Pin]
        let lat = latitude as NSNumber
        let lon = longitude as NSNumber
        
        return pins.filter { pin in
            pin.latitude == lat && pin.longitude == lon
            }.first!
    }
    
    // Prepare for segue to Photo View Controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPhotos" {
            let photoVC = segue.destinationViewController as!
            PhotoViewController
            photoVC.selectedPin = selectedPin
        }
    }
    
// MARK: - Core Data Convenience
    
    // Shared context
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    // Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    // Saving support
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }

}

