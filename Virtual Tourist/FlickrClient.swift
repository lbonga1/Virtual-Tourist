//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/16/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {

// MARK: - Variables
    
    var session: NSURLSession
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
// MARK: - Methods
    
    // Task for 'Get' network call
    func taskForGetMethod(parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        // Build the URL and make the request
        let urlString = FlickrClient.BaseUrls.BaseUrl + FlickrClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
    
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if let error = error {
                let newError = self.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        // Start the request
        task.resume()
    
        return task
    }
    
    // Bounding box
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        // Fix added to ensure box is bounded by minimum and maximums
        let bottom_left_lon = max(longitude - BoundingBox.BoundingBoxHalfWidth, BoundingBox.LonMin)
        let bottom_left_lat = max(latitude - BoundingBox.BoundingBoxHalfHeight, BoundingBox.LatMin)
        let top_right_lon = min(longitude + BoundingBox.BoundingBoxHalfHeight, BoundingBox.LonMax)
        let top_right_lat = min(latitude + BoundingBox.BoundingBoxHalfHeight, BoundingBox.LatMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    // For error debugging
    func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[JsonResponseKeys.StatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Flickr Error", code: 0, userInfo: userInfo)
            }
        }
        return error
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

// MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
// MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}
