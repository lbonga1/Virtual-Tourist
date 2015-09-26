//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/16/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct BaseUrls {
        static let BaseUrl = "https://api.flickr.com/services/rest/"
    }
    
    struct Methods {
        static let PhotoSearch = "flickr.photos.search"
    }
    
    struct MethodKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let BBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let DataFormat = "format"
        static let NsJsonCallBack = "nojsoncallback"
        static let PhotoLimit = "per_page"
        static let Page = "page"
    }
    
    struct MethodValues {
        static let ApiKey = "dbbc00ea0f8db209ae1ebb5233726e56"
        static let SafeSearch = "1"
        static let Extras = "url_m"
        static let DataFormat = "json"
        static let NoJsonCallback = "1"
        static let PhotoLimit = "21"
        static let Page = "1"
    }
    
    struct JsonResponseKeys {
        static let ImagePath = "url_m"
        static let ImageID = "id"
        static let StatusMessage = "message"
        static let SuccessMessage = "stat"
        static let PhotosDictionary = "photos"
        static let PhotosArray = "photo"
    }
    
    struct BoundingBox {
        static let BoundingBoxHalfWidth = 1.0
        static let BoundingBoxHalfHeight = 1.0
        static let LatMin = -90.0
        static let LatMax = 90.0
        static let LonMin = -180.0
        static let LonMax = 180.0
    }
}