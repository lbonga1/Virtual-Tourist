//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/21/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func createBoundingBoxString() -> String {
        
        let latitude = Data.sharedInstance().latitude
        let longitude = Data.sharedInstance().longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - Optionals.BoundingBoxHalfWidth, Optionals.LonMin)
        let bottom_left_lat = max(latitude - Optionals.BoundingBoxHalfHeight, Optionals.LatMin)
        let top_right_lon = min(longitude + Optionals.BoundingBoxHalfHeight, Optionals.LonMax)
        let top_right_lat = min(latitude + Optionals.BoundingBoxHalfHeight, Optionals.LatMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }

    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }

}