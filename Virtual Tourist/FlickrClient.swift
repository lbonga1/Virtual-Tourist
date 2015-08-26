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
    lazy var sharedContext = {CoreDataStackManager.sharedInstance().managedObjectContext!}()
    
    var session: NSURLSession
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
// MARK: - Methods
    
    // Main Get method for flickr
    func taskForResource(parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        
        // Add in the API Key and set paramaters
        mutableParameters["method"] = Methods.PhotoSearch
        mutableParameters["api_key"] = Keys.ApiKey
        mutableParameters["lat"] = parameters["lat"] as! String
        mutableParameters["lon"] = parameters["lon"] as! String
        mutableParameters["per_page"] = Methods.PhotoLimit
        if let pageNumber = parameters["page"] as? String {
            mutableParameters["page"] = pageNumber
        }
        mutableParameters["format"] = Methods.DataFormat
        mutableParameters["nojsoncallback"] = Methods.NoJsonCallback
        //mutableParameters["accuracy"] = Methods.Accuracy
        mutableParameters["safe_search"] = Methods.SafeSearch
        
        
        let urlString = FlickrClient.BaseUrls.BaseUrl + FlickrClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }

    
//    func retrieveImages(){
//        let methodArguments = [
//            "method": Methods.PhotoSearch,
//            "api_key": Keys.ApiKey,
//            "bbox": self.createBoundingBoxString(),
//            "safe_search": Optionals.SafeSearch,
//            "extras": Optionals.Extras,
//            "format": Optionals.DataFormat,
//            "nojsoncallback": Optionals.NoJsonCallback
//        ]
//        getImageFromFlickrBySearch(methodArguments)
//    }
//    
//    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject]) {
//        
//        let session = NSURLSession.sharedSession()
//        let urlString = BaseUrls.BaseUrl + escapedParameters(methodArguments)
//        let url = NSURL(string: urlString)!
//        let request = NSURLRequest(URL: url)
//        
//        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
//            if let error = downloadError {
//                println("Could not complete the request \(error)")
//            } else {
//                var parsingError: NSError? = nil
//                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
//                
//                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {
//                    if let totalPages = photosDictionary["pages"] as? Int {
//                        let pageLimit = min(totalPages, 40)
//                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//                        self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: randomPage)
//                    } else {
//                        println("Cant find key 'pages' in \(photosDictionary)")
//                    }
//                } else {
//                    println("Cant find key 'photos' in \(parsedResult)")
//                }
//            }
//        }
//        
//        task.resume()
//    }
//    
//    func getImageFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int) {
//        
//        /* Add the page to the method's arguments */
//        var withPageDictionary = methodArguments
//        withPageDictionary["page"] = pageNumber
//        
//        let session = NSURLSession.sharedSession()
//        let urlString = BaseUrls.BaseUrl + escapedParameters(withPageDictionary)
//        let url = NSURL(string: urlString)!
//        let request = NSURLRequest(URL: url)
//        
//        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
//            if let error = downloadError {
//                println("Could not complete the request \(error)")
//            } else {
//                var parsingError: NSError? = nil
//                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
//                
//                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {
//                    var totalPhotosVal = 0
//                    if let totalPhotos = photosDictionary["total"] as? String {
//                        totalPhotosVal = (totalPhotos as NSString).integerValue
//                    }
//                    
//                    if totalPhotosVal > 0 {
//                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
//                            var count = 0
//                            for photo in photosArray {
//                                // Grab 21 random images
//                                if count <= 20 {
//                                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
//                                    let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
//                            
//                                    let imageUrlString = photoDictionary["url_m"] as? String
//                                    let imageURL = NSURL(string: imageUrlString!)
//                            
//                                    if let imageData = NSData(contentsOfURL: imageURL!) {
//                                        dispatch_async(dispatch_get_main_queue(), {
//                                            let finalImage = UIImage(data: imageData)
//                                            let photo = Photo(dictionary: photoDictionary, context: self.sharedContext)
//                                            //let photo = Photo.photosFromResults(photosArray)
//                                            Data.sharedInstance().photos.append(photo)
//                                            println("retrieved photo")
//                                            count += 1
//                                        })
//                                    } else {
//                                        println("Image does not exist at \(imageURL)")
//                                    }
//                                } else {
//                                    println("Cant find key 'photo' in \(photosDictionary)")
//                                }
//                            }
//                        }
//                    } else {
//                        println("No photos found.")
//                    }
//                } else {
//                    println("Cant find key 'photos' in \(parsedResult)")
//                }
//            }
//        }
//        task.resume()
//    }
    
// MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }


}
