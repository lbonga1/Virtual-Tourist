//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/21/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    // Flickr API call to get photos using location coordinates
    func getFlickrPhotos(latitude: Double, longitude: Double, page: Float, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        // Set the parameters
        let parameters = [
            MethodKeys.Method: Methods.PhotoSearch,
            MethodKeys.ApiKey: MethodValues.ApiKey,
            MethodKeys.BBox: createBoundingBoxString(latitude, longitude: longitude),
            MethodKeys.SafeSearch: MethodValues.SafeSearch,
            MethodKeys.Extras: MethodValues.Extras,
            MethodKeys.DataFormat: MethodValues.DataFormat,
            MethodKeys.NsJsonCallBack: MethodValues.NoJsonCallback,
            MethodKeys.PhotoLimit: MethodValues.PhotoLimit,
            MethodKeys.Page: String(stringInterpolationSegment: page)
        ]
        // Make the request
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
}