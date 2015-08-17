//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

// MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
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
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinColor = .Red
            pinView!.draggable = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("pin tapped")
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoView") as! PhotoViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
// MARK: - Additional Methods
    func addAnnotation(longPress: UIGestureRecognizer) {
        if (longPress.state == UIGestureRecognizerState.Began) {
            var touchPoint = longPress.locationInView(mapView)
            var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            
        }
        
    }


}

