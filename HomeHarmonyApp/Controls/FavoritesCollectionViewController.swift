//
//  FavoritesCollectionViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/14/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

//
//  SwatchCollectionView.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/1/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class FavoritesCollectionViewController: UICollectionViewController {
    // MARK: Properties
    
    weak internal var delegate: ColorSelectionDelegate?
    internal var rowCount = 4.0
    
    var swatchColors : [Color] = [] {
        didSet {
            self.collectionView?.contentOffset = CGPointZero
            self.collectionView?.reloadData()
        }
    }
    
    func reloadData() {
        self.swatchColors.removeAll()
        if let favoriteUrls = FavoritesDatabase.sharedDatabase().sortedKeys as? [NSURL] {
            favoriteUrls.forEach({ (favoriteUrl) -> () in
                if let favorite = FavoritesDatabase.sharedDatabase()[favoriteUrl] as? Favorite {
                    if let color = favorite.getObject() as? Color {
                        self.swatchColors.append(color)
                    }
                }
            })
        }
        
        if (self.swatchColors.count > 40) {
            self.rowCount = 4
        } else if (self.swatchColors.count > 20) {
            self.rowCount = 3
        } else if (self.swatchColors.count > 10) {
            self.rowCount = 2
        } else {
            self.rowCount = 1
        }
        
        self.collectionView?.reloadData()
    }
    
    var category: ColorCategory! {
        didSet {
            let nscolors = (category?.colors)! as NSSet
            if let colors = nscolors.allObjects as? [Color] {
                self.swatchColors = colors
            }
        }
    }
    
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
                self.collectionView?.selectItemAtIndexPath(path, animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
                self.collectionView?.scrollToItemAtIndexPath(path, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
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
        reloadData()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ExpandingSwatchContainerCell.reuseIdentifier, forIndexPath: indexPath)  as! ExpandingSwatchContainerCell
        
        cell.color = self.swatchColors[indexPath.row]
        
        //cell.expands = self.rowCount == 4
        //self.collectionView?.addSubview(cell)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
        Return `false` because we don't want this `collectionView`'s cells to
        become focused. Instead the `UICollectionView` contained in the cell
        should become focused.
        */
        return true
    }
    
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
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            let extraSpacing = flowLayout.minimumLineSpacing + flowLayout.minimumInteritemSpacing
            let vertSpacing = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom + extraSpacing;
            
            if (rowCount > 1) {
                let size = floor((self.view.frame.size.height - vertSpacing * CGFloat(rowCount - 1)) / CGFloat(rowCount))
                return CGSize(width: size, height: size)
            } else {
                let size = floor(self.view.frame.size.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom)
                return CGSize(width: size, height: size)
            }
        }
        return CGSizeZero
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? SwatchContainerCell
        
        self.delegate?.colorChosen(self, color: cell!.color)
    }
}
