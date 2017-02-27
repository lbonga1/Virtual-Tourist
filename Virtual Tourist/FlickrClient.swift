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
    
    var session: URLSession
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
// MARK: - Methods
    
    // Task for 'Get' network call
    func taskForGetMethod(_ parameters: [String : AnyObject], completionHandler: @escaping CompletionHander) -> URLSessionDataTask {
        // Build the URL and make the request
        let urlString = FlickrClient.BaseUrls.BaseUrl + FlickrClient.escapedParameters(parameters)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
    
        let task = session.dataTask(with: request, completionHandler: {data, response, error in
            if let error = error {
                let newError = self.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }) 
        // Start the request
        task.resume()
    
        return task
    }
    
    // Bounding box
    func createBoundingBoxString(_ latitude: Double, longitude: Double) -> String {
        // Fix added to ensure box is bounded by minimum and maximums
        let bottom_left_lon = max(longitude - BoundingBox.BoundingBoxHalfWidth, BoundingBox.LonMin)
        let bottom_left_lat = max(latitude - BoundingBox.BoundingBoxHalfHeight, BoundingBox.LatMin)
        let top_right_lon = min(longitude + BoundingBox.BoundingBoxHalfHeight, BoundingBox.LonMax)
        let top_right_lat = min(latitude + BoundingBox.BoundingBoxHalfHeight, BoundingBox.LatMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    // For error debugging
    func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        if let parsedResult = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[JsonResponseKeys.StatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Flickr Error", code: 0, userInfo: userInfo)
            }
        }
        return error
    }
    
    // Parsing the JSON
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(nil, error)
        } else {
            completionHandler(parsedResult, nil)
        }
    }
    
    // Helper function: Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            // Make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
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
