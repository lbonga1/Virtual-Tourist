//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/23/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
// MARK: - Outlets
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
