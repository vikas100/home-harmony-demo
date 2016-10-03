//
//  SampleCollectionViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/16/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

internal protocol SampleCellDelegate : NSObjectProtocol {
    func sampleSelected(_ samplePath:String)
}

class SampleTypeViewController: UICollectionViewController {
    
    let reuseIdentifier = "SampleTypeCell"

    let visibleCount = 3.5
    
    weak internal var delegate: SampleCellDelegate?
    
    fileprivate var roomExampleNames : NSMutableArray = []
    fileprivate var roomExampleForType : NSMutableArray = []
    
    let countPerType = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.backgroundColor = UIColor.clear
        self.collectionView!.backgroundView = nil
        
        let roomsPath = getSampleBasePath()
        
        do {
            let rawRoomTypes = try FileManager.default.contentsOfDirectory(atPath: roomsPath!)
            
            for roomType in rawRoomTypes {
                let basePath = "\(roomsPath!)/\(roomType)"
                let projects = try FileManager.default.contentsOfDirectory(atPath: basePath)
                if projects.count >= countPerType {
                    for index in 0 ..< countPerType {
                        let singularRoomType = String(roomType.characters.dropLast())
                        roomExampleNames.add(NSLocalizedString(singularRoomType, comment:""))
                        roomExampleForType.add("\(basePath)/\(projects[index])")
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return roomExampleForType.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        let imageView = cell.viewWithTag(1) as? UIImageView
        // Configure the cell
        
        let roomExamplePath = roomExampleForType[(indexPath as NSIndexPath).row] as! String
        
        imageView!.image = CBImage.getPreview(roomExamplePath)
        
        let imageLabel = cell.viewWithTag(2) as? UILabel
        imageLabel!.text = roomExampleNames[(indexPath as NSIndexPath).row] as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let horizSpacing = flowLayout?.sectionInset.left
        let vertSpacing = (flowLayout?.sectionInset.top)! + (flowLayout?.sectionInset.bottom)!;
        
        let size = min(self.view.frame.size.width / CGFloat(visibleCount) - horizSpacing!, self.view.frame.size.height - vertSpacing)
        return CGSize(width: size, height: size)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let roomExamplePath = roomExampleForType[(indexPath as NSIndexPath).row] as! String
        
        self.delegate?.sampleSelected(roomExamplePath)
    }
}
