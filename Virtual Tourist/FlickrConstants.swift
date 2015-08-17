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
}