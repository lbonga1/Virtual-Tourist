//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/21/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getFlickrPhotos(latitude: Double, longitude: Double, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        // Set the parameters
        let parameters = [
            MethodKeys.Method: Methods.PhotoSearch,
            MethodKeys.ApiKey: MethodValues.ApiKey,
            MethodKeys.BBox: createBoundingBoxString(latitude, longitude: longitude),
            MethodKeys.SafeSearch: MethodValues.SafeSearch,
            MethodKeys.Extras: MethodValues.Extras,
            MethodKeys.DataFormat: MethodValues.DataFormat,
            MethodKeys.NsJsonCallBack: MethodValues.NoJsonCallback,
            MethodKeys.PhotoLimit: MethodValues.PhotoLimit
        ]
        
        taskForGetMethod(parameters) { JsonResult, error in
            if let error = error {
                completionHandler(result: nil, error: NSError(domain: "getFlickrPhotos", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
            } else {
                if let successMessage = JsonResult.valueForKey(JsonResponseKeys.SuccessMessage) as? String {
                    if successMessage == "ok" {
                        if let photosDictionary = JsonResult.valueForKey(JsonResponseKeys.PhotosDictionary) as? [String: AnyObject] {
                            if let photosArray = photosDictionary[JsonResponseKeys.PhotosArray] as? [[String: AnyObject]] {
                                completionHandler(result: photosArray, error: nil)
                            } else {
                                completionHandler(result: nil, error: NSError(domain: "getFlickrPhotos", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not find photos array"]))
                            }
                        } else {
                            completionHandler(result: nil, error: NSError(domain: "getFlickrPhotos", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not find photos dictionary"]))
                        }
                    } else {
                        completionHandler(result: nil, error: NSError(domain: "getFlickrPhotos", code: 3, userInfo: [NSLocalizedDescriptionKey: "Server Error"]))
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getFlickrPhotos", code: 2, userInfo: [NSLocalizedDescriptionKey: "Server Error"]))
                }
            }
        }
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
//        let latitude = Data.sharedInstance().latitude
//        let longitude = Data.sharedInstance().longitude
        
        // Fix added to ensure box is bounded by minimum and maximums
        let bottom_left_lon = max(longitude - BoundingBox.BoundingBoxHalfWidth, BoundingBox.LonMin)
        let bottom_left_lat = max(latitude - BoundingBox.BoundingBoxHalfHeight, BoundingBox.LatMin)
        let top_right_lon = min(longitude + BoundingBox.BoundingBoxHalfHeight, BoundingBox.LonMax)
        let top_right_lat = min(latitude + BoundingBox.BoundingBoxHalfHeight, BoundingBox.LatMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    // Parsing the JSON
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[JsonResponseKeys.StatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Flickr Error", code: 0, userInfo: userInfo)
            }
        }
        return error
    }

    // Helper function: Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // Make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
// MARK: - Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }
}