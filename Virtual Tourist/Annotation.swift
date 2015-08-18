//
//  Annotation.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/17/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class Annotation: NSObject, MKAnnotation {
    
    private var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return location
        }
    }
    
//    var title: String = ""
//    var subtitle: String = ""
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.location = newCoordinate
    }
}
