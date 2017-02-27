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
    
    fileprivate var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        return location
    }
    
    func setCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        willChangeValue(forKey: "coordinate")
        self.location = newCoordinate
        didChangeValue(forKey: "coordinate")
    }
}
