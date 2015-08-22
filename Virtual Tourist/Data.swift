//
//  Data.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/21/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class Data: NSObject {
 
    var photos: [Photo]!
    
    var latitude = 0.0
    var longitude = 0.0
    
// MARK: - Shared Instance
    
    class func sharedInstance() -> Data {
        
        struct Singleton {
            static var sharedInstance = Data()
        }
        
        return Singleton.sharedInstance
    }
}
