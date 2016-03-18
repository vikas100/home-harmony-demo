//
//  NewsTutorialViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/17/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

internal protocol MainActionDelegate : NSObjectProtocol {
    func visualizerAction()
    func samplesAction()
    func colorsAction()
}

class MainActionCell: UICollectionViewCell
{
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
}

class MainActionsViewController: UICollectionViewController {
    
    weak internal var delegate: MainActionDelegate?
    
    let visibleCount = 3
    var actionTitles: NSMutableArray!
    var actionImages: NSMutableArray!
    
    let reuseIdentifier = "MainActionCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.backgroundColor = UIColor.clearColor()
        self.collectionView!.backgroundView = nil
        
        self.actionTitles = NSMutableArray()
        self.actionImages = NSMutableArray()
        
        self.actionTitles.addObject(NSLocalizedString("Visualizer", comment: ""))
        self.actionImages.addObject(UIImage(named: "VisualizerAction")!)
        self.actionTitles.addObject(NSLocalizedString("Sample Room", comment: ""))
        self.actionImages.addObject(UIImage(named: "SamplesAction")!)
        self.actionTitles.addObject(NSLocalizedString("Match a Photo", comment: ""))
        self.actionImages.addObject(UIImage(named: "SwatchesAction")!)
        
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
        return actionTitles.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? MainActionCell else { fatalError("Expected to display a MainActionCell") }
        // Configure the cell

        cell.actionLabel.text = self.actionTitles[indexPath.row] as? String
        cell.actionImageView.image = self.actionImages[indexPath.row] as? UIImage
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.delegate?.visualizerAction()
        }
        else if indexPath.row == 1 {
            self.delegate?.samplesAction()
        }
        else if indexPath.row == 2 {
            self.delegate?.colorsAction()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let horizSpacing = flowLayout?.sectionInset.left
        let vertSpacing = (flowLayout?.sectionInset.top)! + (flowLayout?.sectionInset.bottom)!;
        
        let size = min(self.view.frame.size.width / CGFloat(visibleCount) - horizSpacing!, self.view.frame.size.height - vertSpacing)
        return CGSize(width: size, height: size)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
