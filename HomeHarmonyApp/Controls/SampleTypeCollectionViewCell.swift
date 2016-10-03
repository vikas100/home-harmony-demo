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
    
    fileprivate var roomType : String!
    fileprivate var projectPaths = [String]()
    
    func configureWithRoomType(_ roomType: String) {
        self.roomType = roomType
        self.headingLabel.text = roomType
        
        do {
            let roomTypePath = getSampleTypePath(self.roomType)
            try projectPaths = FileManager.default.contentsOfDirectory(atPath: roomTypePath!)
        }
        catch let error as NSError {
            error.description
        }
                
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectPaths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SampleTypeCollectionViewCell.reuseIdentifier, for: indexPath)
        
        let imageView = cell.viewWithTag(1) as? UIImageView
        // Configure the cell
        
        let projectID = projectPaths[(indexPath as NSIndexPath).row]
        let projectPath = getSampleProjectPath(self.roomType, projectID: projectID)
        imageView!.image = CBImage.getPreview(projectPath)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //guard let cell = cell as? SampleTypeCollectionViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
        //let projectDirectoryPath = rootDirectoryPath + "/" + projectPaths[indexPath.row]
        
        // Configure the cell.
        //cellComposer.composeCell(cell, projectPath:projectDirectoryPath, usePreview:true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let projectID = projectPaths[(indexPath as NSIndexPath).row]
        let projectPath = getSampleProjectPath(self.roomType, projectID: projectID)
        self.delegate?.sampleSelected(projectPath!)
    }

}
