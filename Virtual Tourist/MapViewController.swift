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
    
    var pins = Set<Pin>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Long press gesture
        var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        gesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(gesture)
    
    }

// MARK: - MKMapViewDelegate
    
    // Creates a draggable annotation.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is Annotation {
            let reuseId = "pin"
        
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.pinColor = .Green
                pinView!.draggable = true
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
            
            // Add pin to set
            let selectedPin = Pin()
            var select = "\(pinLat.hashValue),\(pinLon.hashValue)".hashValue
            pins.insert(selectedPin)
            
            // Save to Core Data
            self.saveContext()
            
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
        if (longPress.state == UIGestureRecognizerState.Began) {
            var touchPoint = longPress.locationInView(mapView)
            var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = Annotation()
            //annotation.coordinate = newCoordinates
            annotation.setCoordinate(newCoordinates)
            mapView.addAnnotation(annotation)
            
            // Save to Core Data
            self.saveContext()
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

