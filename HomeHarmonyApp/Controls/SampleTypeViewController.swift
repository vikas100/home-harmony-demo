//
//  SampleCollectionViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/16/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

internal protocol SampleCellDelegate : NSObjectProtocol {
    func sampleSelected(samplePath:String)
}

class SampleTypeViewController: UICollectionViewController {
    
    let reuseIdentifier = "SampleTypeCell"

    let visibleCount = 3.5
    
    weak internal var delegate: SampleCellDelegate?
    
    private var roomExampleNames : NSMutableArray = []
    private var roomExampleForType : NSMutableArray = []
    
    let countPerType = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.backgroundColor = UIColor.clearColor()
        self.collectionView!.backgroundView = nil
        
        let roomsPath = getSampleBasePath()
        
        do {
            let rawRoomTypes = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(roomsPath)
            
            for roomType in rawRoomTypes {
                let basePath = "\(roomsPath!)/\(roomType)"
                let projects = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(basePath)
                if projects.count >= countPerType {
                    for var index = 0; index < countPerType; ++index {
                        let singularRoomType = String(roomType.characters.dropLast())
                        roomExampleNames.addObject(NSLocalizedString(singularRoomType, comment:""))
                        roomExampleForType.addObject("\(basePath)/\(projects[index])")
                    }
                }
            }
        }
        catch let error as NSError {
            error.description
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return roomExampleForType.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        let imageView = cell.viewWithTag(1) as? UIImageView
        // Configure the cell
        
        let roomExamplePath = roomExampleForType[indexPath.row] as! String
        
        imageView!.image = CBImage.getPreview(roomExamplePath)
        
        let imageLabel = cell.viewWithTag(2) as? UILabel
        imageLabel!.text = roomExampleNames[indexPath.row] as? String
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let horizSpacing = flowLayout?.sectionInset.left
        let vertSpacing = (flowLayout?.sectionInset.top)! + (flowLayout?.sectionInset.bottom)!;
        
        let size = min(self.view.frame.size.width / CGFloat(visibleCount) - horizSpacing!, self.view.frame.size.height - vertSpacing)
        return CGSize(width: size, height: size)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let roomExamplePath = roomExampleForType[indexPath.row] as! String
        
        self.delegate?.sampleSelected(roomExamplePath)
    }
}
