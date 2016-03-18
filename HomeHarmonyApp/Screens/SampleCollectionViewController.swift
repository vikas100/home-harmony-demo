//
//  SampleCollectionViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/16/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

class SampleCollectionViewController: UICollectionViewController, SampleCellDelegate {
    
    let reuseIdentifier = "SampleTypeCollectionCell"
    
    weak internal var delegate: SampleCellDelegate?
    
    private var roomTypes : NSMutableArray = []
    private var roomExampleForType : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = false
        
        let roomsPath = getSampleBasePath()
        
        do {
            let rawRoomTypes = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(roomsPath)
            
            for roomType in rawRoomTypes {
                let basePath = "\(roomsPath!)/\(roomType)"
                let projects = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(basePath)
                if projects.count > 0 {
                    roomTypes.addObject(NSLocalizedString(roomType, comment:""))
                    roomExampleForType.addObject("\(basePath)/\(projects[0])")
                }
            }
        }
        catch let error as NSError {
            error.description
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return roomTypes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)  as! SampleTypeCollectionViewCell
        
        let roomType = roomTypes[indexPath.row] as! String
        cell.configureWithRoomType(roomType)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        
        let defaultSize = flowLayout?.itemSize;
        
        return CGSize(width: self.view.frame.size.width, height: (defaultSize?.height)!)
        
    }
    
    func sampleSelected(samplePath:String) {
        
        self.navigationController!.popViewControllerAnimated(false)
        self.delegate?.sampleSelected(samplePath)
        //self.performSegueWithIdentifier("showSampleProject", sender: self)
    }
    
}
