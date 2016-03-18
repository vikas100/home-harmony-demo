//
//  OptionsCollection.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/6/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

private let reuseIdentifier = "OptionCell"

internal protocol OptionCellDelegate : NSObjectProtocol {
    func optionSelected(option:Option)
}

class OptionCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
}

class Option {
    var id: Int
    var title: String
    var image: UIImage!
    var minWidth: CGFloat
    var enabled = true
    var visibleCount = 4.0
    
    init(id: Int, title: String, image:UIImage!, minWidth:CGFloat) {
        self.id = id
        self.title = title
        self.image = image
        self.minWidth = minWidth
    }
}

class OptionsCollectionViewController: UICollectionViewController {
    
    weak internal var delegate: OptionCellDelegate?
    var requiredWidth:CGFloat!
    
    private var options = [Option]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.backgroundColor = UIColor.clearColor()
        self.collectionView!.backgroundView = nil
        
    }
    
    func loadOptions(options: [Option]) {
        self.options = options
        
        requiredWidth = 0
        options.forEach{ requiredWidth = requiredWidth + $0.minWidth }
        
        self.collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.options.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? OptionCell
        
        let option = self.options[indexPath.row]
        
        //print("Title:\(option.title)")
        
        if let cell = cell {
            cell.button.setTitle(option.title, forState: UIControlState.Normal)
            cell.button.setImage(option.image, forState: UIControlState.Normal)
            cell.button.enabled = option.enabled
            cell.button.tag = indexPath.row
            cell.button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        }
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let horizSpacing = flowLayout?.minimumInteritemSpacing
        //let vertSpacing = (flowLayout?.sectionInset.top)! + (flowLayout?.sectionInset.bottom)!;
        
        let option = self.options[indexPath.row]
        
        let leftoverWidth = max(self.view.frame.size.width - self.requiredWidth - horizSpacing! * CGFloat(self.options.count - 1), 0)
        let extraWidth = leftoverWidth / CGFloat(self.options.count)
        let width = option.minWidth + extraWidth
        
        return CGSize(width: width, height: self.view.frame.size.height)
    }
    
    func pressed(button:UIButton) {
        let option = self.options[button.tag]
        self.delegate?.optionSelected(option)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let option = self.options[indexPath.row]
        self.delegate?.optionSelected(option)
    }
}
