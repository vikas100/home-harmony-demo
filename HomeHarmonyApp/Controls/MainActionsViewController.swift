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

        self.collectionView!.backgroundColor = UIColor.clear
        self.collectionView!.backgroundView = nil
        
        self.actionTitles = NSMutableArray()
        self.actionImages = NSMutableArray()
        
        self.actionTitles.add(NSLocalizedString("Visualizer", comment: ""))
        self.actionImages.add(UIImage(named: "VisualizerAction")!)
        self.actionTitles.add(NSLocalizedString("Sample Room", comment: ""))
        self.actionImages.add(UIImage(named: "SamplesAction")!)
        self.actionTitles.add(NSLocalizedString("Match a Photo", comment: ""))
        self.actionImages.add(UIImage(named: "SwatchesAction")!)
        
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
        return actionTitles.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MainActionCell else { fatalError("Expected to display a MainActionCell") }
        // Configure the cell

        cell.actionLabel.text = self.actionTitles[(indexPath as NSIndexPath).row] as? String
        cell.actionImageView.image = self.actionImages[(indexPath as NSIndexPath).row] as? UIImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            self.delegate?.visualizerAction()
        }
        else if (indexPath as NSIndexPath).row == 1 {
            self.delegate?.samplesAction()
        }
        else if (indexPath as NSIndexPath).row == 2 {
            self.delegate?.colorsAction()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
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
