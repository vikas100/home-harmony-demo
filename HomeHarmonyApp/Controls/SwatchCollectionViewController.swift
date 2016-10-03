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
            self.collectionView?.contentOffset = CGPoint.zero
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
        if let items = self.collectionView?.indexPathsForSelectedItems {
            items.forEach({ (path) -> () in
                self.collectionView?.deselectItem(at: path, animated: false)
            })
        }
    }
    
    func selectColor(_ color:Color!) {
        self.deselectAll()
        
        if (color != nil){
            if let i = self.swatchColors.index(where: {$0.name == color.name}) {
                let path = IndexPath(row: i, section: 0)
                self.collectionView?.selectItem(at: path, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            }
        }
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.backgroundColor = UIColor.clear
        self.collectionView!.backgroundView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.favoriteColors.removeAll()
        if let favoriteUrls = FavoritesDatabase.sharedDatabase().sortedKeys as? [URL] {
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Our collection view displays 1 section per group of items.
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section contains a single `CollectionViewContainerCell`.
        return swatchColors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SwatchContainerCell.reuseIdentifier, for: indexPath)  as! SwatchContainerCell
        
        cell.color = self.swatchColors[(indexPath as NSIndexPath).row]
        
        //self.collectionView?.addSubview(cell)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func projectSelected(_ projectPath:String) {
        //selectedProjectPath = projectPath
        performSegue(withIdentifier: "showPainter", sender: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)
        
        self.collectionView?.addSubview(cell!)
        
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        
        let cell = collectionView.cellForItem(at: indexPath)
        if (cell?.superview != nil) {
            cell?.removeFromSuperview()
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let vertSpacing = (flowLayout?.sectionInset.top)! + (flowLayout?.sectionInset.bottom)!;
        
        if (rowCount > 1) {
            let size = floor((self.view.frame.size.height - vertSpacing * CGFloat(rowCount - 1)) / CGFloat(rowCount))
            return CGSize(width: size, height: size)
        } else {
            return (flowLayout?.itemSize)!
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as? SwatchContainerCell

        self.delegate?.colorChosen(self, color: cell!.color)
    }
}
