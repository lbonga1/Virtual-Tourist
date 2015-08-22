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
        static let BaseUrl: String = "https://api.flickr.com/services/rest/"
    }
    
    struct Methods {
        static let PhotoSearch: String = "flickr.photos.search"
    }
    
    struct Keys {
        static let ApiKey: String = "dbbc00ea0f8db209ae1ebb5233726e56"
        static let Secret: String = "e853d3863b1c9068"
    }
    
    struct Optionals {
        static let Extras = "url_m"
        static let SafeSearch = "1"
        static let DataFormat = "json"
        static let NoJsonCallback = "1"
        static let BoundingBoxHalfWidth = 1.0
        static let BoundingBoxHalfHeight = 1.0
        static let LatMin = -90.0
        static let LatMax = 90.0
        static let LonMin = -180.0
        static let LonMax = 180.0
    }
}