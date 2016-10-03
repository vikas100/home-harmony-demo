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
    func optionSelected(_ option:Option)
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
    
    fileprivate var options = [Option]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.backgroundColor = UIColor.clear
        self.collectionView!.backgroundView = nil
        
    }
    
    func loadOptions(_ options: [Option]) {
        self.options = options
        
        requiredWidth = 0
        options.forEach{ requiredWidth = requiredWidth + $0.minWidth }
        
        self.collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.options.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? OptionCell
        
        let option = self.options[(indexPath as NSIndexPath).row]
        
        //print("Title:\(option.title)")
        
        if let cell = cell {
            cell.button.setTitle(option.title, for: UIControlState())
            cell.button.setImage(option.image, for: UIControlState())
            cell.button.isEnabled = option.enabled
            cell.button.tag = (indexPath as NSIndexPath).row
            cell.button.addTarget(self, action: #selector(OptionsCollectionViewController.pressed(_:)), for: .touchUpInside)
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let horizSpacing = flowLayout?.minimumInteritemSpacing
        //let vertSpacing = (flowLayout?.sectionInset.top)! + (flowLayout?.sectionInset.bottom)!;
        
        let option = self.options[(indexPath as NSIndexPath).row]
        
        let leftoverWidth = max(self.view.frame.size.width - self.requiredWidth - horizSpacing! * CGFloat(self.options.count - 1), 0)
        let extraWidth = leftoverWidth / CGFloat(self.options.count)
        let width = option.minWidth + extraWidth
        
        return CGSize(width: width, height: self.view.frame.size.height)
    }
    
    func pressed(_ button:UIButton) {
        let option = self.options[button.tag]
        self.delegate?.optionSelected(option)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = self.options[(indexPath as NSIndexPath).row]
        self.delegate?.optionSelected(option)
    }
}
