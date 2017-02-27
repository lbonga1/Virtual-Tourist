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
    func getFlickrPhotos(_ latitude: Double, longitude: Double, page: Float, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
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
        taskForGetMethod(parameters as [String : AnyObject]) { JsonResult, error in
            if let error = error {
                print("error code: \(error.code)")
                print("error description: \(error.localizedDescription)")
                completionHandler(nil, NSError(domain: "getFlickrPhotos", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
            } else {
                if let successMessage = JsonResult?.value(forKey: JsonResponseKeys.SuccessMessage) as? String {
                    if successMessage == "ok" {
                        if let photosDictionary = JsonResult?.value(forKey: JsonResponseKeys.PhotosDictionary) as? [String: AnyObject] {
                            if let photosArray = photosDictionary[JsonResponseKeys.PhotosArray] as? [[String: AnyObject]] {
                                completionHandler(photosArray as AnyObject?, nil)
                            } else {
                                completionHandler(nil, NSError(domain: "getFlickrPhotos", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not find photos array"]))
                            }
                        } else {
                            completionHandler(nil, NSError(domain: "getFlickrPhotos", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not find photos dictionary"]))
                        }
                    } else {
                        completionHandler(nil, NSError(domain: "getFlickrPhotos", code: 3, userInfo: [NSLocalizedDescriptionKey: "Server Error"]))
                    }
                } else {
                    completionHandler(nil, NSError(domain: "getFlickrPhotos", code: 2, userInfo: [NSLocalizedDescriptionKey: "Server Error"]))
                }
            }
        }
    }
}
