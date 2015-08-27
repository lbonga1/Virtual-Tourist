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

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

// MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
// MARK: - Variables
    var pins = Set<Pin>()
    var annotationToBeAdded: Annotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Long press gesture
        var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        gesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(gesture)
        
        // Retrieve map region data
        if let mapInfo: [ String : CLLocationDegrees ] = NSUserDefaults.standardUserDefaults().dictionaryForKey("mapInfo") as? [ String : CLLocationDegrees ] {
            var mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: mapInfo[ "centerLatitude" ]!,
                    longitude: mapInfo[ "centerLongitude" ]!
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: (mapInfo[ "spanLatitudeDelta" ]!),
                    longitudeDelta: (mapInfo[ "spanLongitudeDelta" ]!)
                )
            )
            mapView.region = mapRegion
        } else {
            println("Map info unavailable.")
        }
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        self.fetchAllPins()
    }

// MARK: - MKMapViewDelegate
    
    // Saves map's region when changed.
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        let mapRegionCenterLatitude: CLLocationDegrees = mapView.region.center.latitude
        let mapRegionCenterLongitude: CLLocationDegrees = mapView.region.center.longitude
        let mapRegionSpanLatitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
        let mapRegionSpanLongitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta
        
        var mapDictionary: [ String : CLLocationDegrees ] = [ String : CLLocationDegrees ]()
        mapDictionary.updateValue(mapRegionCenterLatitude, forKey: "centerLatitude" )
        mapDictionary.updateValue(mapRegionCenterLongitude, forKey: "centerLongitude" )
        mapDictionary.updateValue(mapRegionSpanLatitudeDelta, forKey: "spanLatitudeDelta" )
        mapDictionary.updateValue(mapRegionSpanLongitudeDelta, forKey: "spanLongitudeDelta" )
        
        NSUserDefaults.standardUserDefaults().setObject(mapDictionary, forKey: "mapInfo" )
    }
    
    // Create annotation.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is Annotation {
            let reuseId = "pin"
        
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.pinColor = .Green
                pinView!.animatesDrop = true
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
            
            let selected = view.annotation
            let lat = selected.coordinate.latitude
            var pinLat = view.annotation.coordinate.latitude
            var pinLon = view.annotation.coordinate.longitude
            var select = "\(pinLat.hashValue),\(pinLon.hashValue)".hashValue
            
            // Get PhotoViewController
            for pin in pins {
                if pin.hashValue == select.hashValue {
                    dispatch_async(dispatch_get_main_queue()) {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let photoVC = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoView") as! PhotoViewController
                        self.navigationController?.pushViewController(photoVC, animated: true)
                    }
                }
            }
            
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
            
            let pin = Pin(location: newCoordinates, context: self.sharedContext)
            let parameters :[String:AnyObject] = ["lat":"\(pin.latitude)", "lon":"\(pin.longitude)"]
            
//            // Pre-fetch images from Flickr
//            FlickrClient.sharedInstance().taskForResource(parameters) { [unowned self] jsonResult, error in
//                
//                // Handle the error case
//                if let error = error {
//                    println("Error searching for photos: \(error.localizedDescription)")
//                    return
//                }
//                
//                // Get a Swift dictionary from the JSON data
//                if let photosDictionary = jsonResult.valueForKey("photos") as? [String : AnyObject] {
////                    // Get total pages
////                    if let maxPages = photosDictionary["pages"] as? NSNumber {
////                        pin.pages = maxPages
////                    }
////                    // Get current page number
////                    if let pageNumber = photosDictionary["page"] as? NSNumber {
////                        pin.page = pageNumber
////                    }
//                    if let photoDictionary = photosDictionary["photo"] as? [[String : AnyObject]] {
//                        // Build Photo array
//                        var photos = photoDictionary.map() {
//                            Photo(pin: pin, dictionary: $0, context: self.sharedContext)
//                        }
//                        
//                        var error:NSError? = nil
//                        
//                        self.sharedContext.save(&error)
//                        
//                        if let error = error {
//                            //self.alert("Error saving context")
//                            println("error saving context: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            }

            
            // Save to Core Data
            self.saveContext()
            
        case .Changed:
            annotationToBeAdded!.setCoordinate(newCoordinates)
            
        case .Ended:
            annotationToBeAdded!.setCoordinate(newCoordinates)
            
            // Add pin to set
            let selectedPin = Pin()
            pins.insert(selectedPin)
            
        default:
            return
        }
    }
    
    // Fetch all persistent pins.
    func fetchAllPins() -> [Pin] {
        let error: NSErrorPointer = nil
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        // Check for Errors
        if error != nil {
            println("Error in fectchAllActors(): \(error)")
        }
        
        // Return the results, cast to an array of Person objects
        return results as! [Pin]
    }
    
// MARK: - Core Data Convenience
    
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }

}

