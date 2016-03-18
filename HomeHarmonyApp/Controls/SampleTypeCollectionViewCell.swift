//
//  SampleTypeCollectionViewCell.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/24/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class SampleTypeCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    static let reuseIdentifier = "SampleCell"
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak internal var delegate: SampleCellDelegate?
    
    private var roomType : String!
    private var projectPaths = [String]()
    
    func configureWithRoomType(roomType: String) {
        self.roomType = roomType
        self.headingLabel.text = roomType
        
        do {
            let roomTypePath = getSampleTypePath(self.roomType)
            try projectPaths = NSFileManager.defaultManager().contentsOfDirectoryAtPath(roomTypePath)
        }
        catch let error as NSError {
            error.description
        }
                
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectPaths.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SampleTypeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
        
        let imageView = cell.viewWithTag(1) as? UIImageView
        // Configure the cell
        
        let projectID = projectPaths[indexPath.row]
        let projectPath = getSampleProjectPath(self.roomType, projectID: projectID)
        imageView!.image = CBImage.getPreview(projectPath)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //guard let cell = cell as? SampleTypeCollectionViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
        //let projectDirectoryPath = rootDirectoryPath + "/" + projectPaths[indexPath.row]
        
        // Configure the cell.
        //cellComposer.composeCell(cell, projectPath:projectDirectoryPath, usePreview:true)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let projectID = projectPaths[indexPath.row]
        let projectPath = getSampleProjectPath(self.roomType, projectID: projectID)
        self.delegate?.sampleSelected(projectPath)
    }

}