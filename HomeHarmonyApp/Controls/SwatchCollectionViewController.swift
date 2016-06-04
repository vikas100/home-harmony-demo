//
//  SwatchCollectionView.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/1/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class SwatchCollectionViewController: UICollectionViewController {
    // MARK: Properties
    
    weak internal var delegate: ColorSelectionDelegate?
    internal var rowCount = 4.0
    
    var swatchColors : [Color] = [] {
        didSet {
            self.collectionView?.contentOffset = CGPointZero
            self.collectionView?.reloadData()
        }
    }
    
    var category: ColorCategory! {
        didSet {
            let nscolors = (category?.colors)! as NSSet
            if let colors = nscolors.allObjects as? [Color] {
                self.swatchColors = colors
            }
        }
    }
    
    var favoriteColors : [Color] = []
    
    func deselectAll() {
        if let items = self.collectionView?.indexPathsForSelectedItems() {
            items.forEach({ (path) -> () in
                self.collectionView?.deselectItemAtIndexPath(path, animated: false)
            })
        }
    }
    
    func selectColor(color:Color!) {
        self.deselectAll()
        
        if (color != nil){
            if let i = self.swatchColors.indexOf({$0.name == color.name}) {
                let path = NSIndexPath(forRow: i, inSection: 0)
                self.collectionView?.selectItemAtIndexPath(path, animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
            }
        }
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.backgroundColor = UIColor.clearColor()
        self.collectionView!.backgroundView = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        self.favoriteColors.removeAll()
        if let favoriteUrls = FavoritesDatabase.sharedDatabase().sortedKeys as? [NSURL] {
            favoriteUrls.forEach({ (favoriteUrl) -> () in
                if let favorite = FavoritesDatabase.sharedDatabase()[favoriteUrl] as? Favorite {
                    if let color = favorite.getObject() as? Color {
                        self.favoriteColors.append(color)
                    }
                }
            })
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Our collection view displays 1 section per group of items.
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section contains a single `CollectionViewContainerCell`.
        return swatchColors.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SwatchContainerCell.reuseIdentifier, forIndexPath: indexPath)  as! SwatchContainerCell
        
        cell.color = self.swatchColors[indexPath.row]
        
        //self.collectionView?.addSubview(cell)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func projectSelected(projectPath:String) {
        //selectedProjectPath = projectPath
        performSegueWithIdentifier("showPainter", sender: self)
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        self.collectionView?.addSubview(cell!)
        
        return true
    }

    override func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if (cell?.superview != nil) {
            cell?.removeFromSuperview()
        }
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let vertSpacing = (flowLayout?.sectionInset.top)! + (flowLayout?.sectionInset.bottom)!;
        
        if (rowCount > 1) {
            let size = floor((self.view.frame.size.height - vertSpacing * CGFloat(rowCount - 1)) / CGFloat(rowCount))
            return CGSize(width: size, height: size)
        } else {
            return (flowLayout?.itemSize)!
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? SwatchContainerCell

        self.delegate?.colorChosen(self, color: cell!.color)
    }
}
