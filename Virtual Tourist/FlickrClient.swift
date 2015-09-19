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

    
// MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
//// MARK: - Core Data convenience
//    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
}
