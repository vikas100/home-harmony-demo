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
    
    fileprivate var roomTypes : NSMutableArray = []
    fileprivate var roomExampleForType : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        let roomsPath = getSampleBasePath()
        
        do {
            let rawRoomTypes = try FileManager.default.contentsOfDirectory(atPath: roomsPath!)
            
            for roomType in rawRoomTypes {
                let basePath = "\(roomsPath!)/\(roomType)"
                let projects = try FileManager.default.contentsOfDirectory(atPath: basePath)
                if projects.count > 0 {
                    roomTypes.add(NSLocalizedString(roomType, comment:""))
                    roomExampleForType.add("\(basePath)/\(projects[0])")
                }
            }
        }
        catch let error as NSError {
            error.description
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return roomTypes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)  as! SampleTypeCollectionViewCell
        
        let roomType = roomTypes[(indexPath as NSIndexPath).row] as! String
        cell.configureWithRoomType(roomType)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        
        let defaultSize = flowLayout?.itemSize;
        
        return CGSize(width: self.view.frame.size.width, height: (defaultSize?.height)!)
        
    }
    
    func sampleSelected(_ samplePath:String) {
        
        self.navigationController!.popViewController(animated: false)
        self.delegate?.sampleSelected(samplePath)
        //self.performSegueWithIdentifier("showSampleProject", sender: self)
    }
    
}
