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
    
    // Creates a draggable annotation.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is Annotation {
            let reuseId = "pin"
        
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.pinColor = .Green
                //pinView!.draggable = true
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
        let annotation = Annotation()
        
        switch longPress.state {
        case .Began:
            annotation.setCoordinate(newCoordinates)
            mapView.addAnnotation(annotation)
            FlickrClient.sharedInstance().retrieveImages()
            
        case .Changed:
            annotation.setCoordinate(newCoordinates)
            
        case .Ended:
            annotation.setCoordinate(newCoordinates)
            
            // Add pin to set
            let selectedPin = Pin()
            pins.insert(selectedPin)
            
            // Save to Core Data
            self.saveContext()
            
        default:
            return
        }
    }
    
// MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }

}

