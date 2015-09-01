//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Lauren Bongartz on 8/12/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit
import MapKit

class PhotoViewController: UIViewController {
    
// MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
// MARK: - Variables
    
    var pin: Pin?
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.collectionView.reloadData()
        
        if photos.isEmpty {
        
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // Collection View cell information
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Assigns custom cell.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! CollectionViewCell
        let photo = photos[indexPath.item]
        //var photoImage = UIImage(named: "NoImage")
        //cell.activityView.hidesWhenStopped
        
        
        return cell
    }

    // Allows for editing collectionView cells.
    func collectionView(collectionView: UICollectionView, canEditItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
        
    // Changes cell opacity and updates delete button title when deselected.
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.alpha = 1.0
        //updateDeleteButtonTitle()
    }
}
