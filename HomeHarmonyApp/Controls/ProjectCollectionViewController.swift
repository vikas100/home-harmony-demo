//
//  ProjectCollectionViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/16/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ProjectCell"

internal protocol ProjectCellDelegate : NSObjectProtocol {
    func projectSelected(samplePath:String)
}

class ProjectCollectionViewController: UICollectionViewController {
    
    weak internal var delegate: ProjectCellDelegate?
    let visibleCount = 3.5

    private var projects: [Project] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.backgroundColor = UIColor.clearColor()
        self.collectionView!.backgroundView = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        self.projects.removeAll()
        
        if let projectIDs = ProjectDatabase.sharedDatabase().sortedKeys as? [String] {
            projectIDs.forEach({ (projectID) -> () in
                if let project = ProjectDatabase.sharedDatabase()[projectID] as? Project {
                    self.projects.append(project)
                }
            })
        }
        
        self.collectionView?.reloadData()
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
        return self.projects.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        let project = self.projects[indexPath.row]
        
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = project.previewImage
        }
        
        if let imageLabel = cell.viewWithTag(2) as? UILabel {
            imageLabel.text = project.name
        }
        
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
        let project = self.projects[indexPath.row]
        self.delegate?.projectSelected(project.path)
    }
}
