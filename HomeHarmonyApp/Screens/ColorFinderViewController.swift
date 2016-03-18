//
//  ColorFinderViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/17/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

class ColorFinderViewController: UIViewController {

    @IBOutlet weak var currentColorView: UIView!
    @IBOutlet weak var colorFinder: CBColorFinder!
    @IBOutlet weak var visualizerButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBOutlet weak var reshootButton: UIButton!
    @IBOutlet weak var libraryButton: LibraryThumbnailButton!
    
    @IBOutlet weak var colorNameLabel: UILabel!
    @IBOutlet weak var colorCodeLabel: UILabel!
    @IBOutlet weak var primaryColorView: UIView!
    
    @IBOutlet weak var currentColorViewX: NSLayoutConstraint!
    @IBOutlet weak var currentColorViewY: NSLayoutConstraint!
    
    var image:UIImage!
    var selectedColor:Color!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up camera and library
        
        self.currentColorView.hidden = true
        self.colorNameLabel.hidden = true
        self.colorCodeLabel.hidden = true
        self.favoritesButton.hidden = true
        self.visualizerButton.hidden = true
        
        self.reshootButton.hidden = !ImageManager.sharedInstance.hasCamera()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.navigationBar.hidden = false
        
        //load an image if none yet
        if let _ = image {
            self.loadImage(image)
            self.image = nil
        }
        
        colorFinder.colorTouchedAtPoint = ({
            [weak self]
            (touchType: TouchStep, point:CGPoint, color:UIColor!) in
            
            if let strongSelf = self {
//                let pointInView = CGPoint(x:point.x + (self?.colorFinder.frame.origin.x)!,
//                    y:point.y + (self?.colorFinder.frame.origin.y)!)
                
                CBThreading.performBlock({ () -> Void in
                    if let dataColor = Color.closestMatchForUIColor(color, brand: nil, category: nil, excludingColors: nil) {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            strongSelf.colorChosen(strongSelf, color: dataColor)
                        })
                    }
                    }, onQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), withIdentifier: "ColorFinder",
                       interval:1.0)
                
                if (touchType == TouchStepEnded) {
                    strongSelf.reshootButton.hidden = !ImageManager.sharedInstance.hasCamera()
                    strongSelf.currentColorView.hidden = false
                } else {
                    strongSelf.libraryButton.hidden = true
                    strongSelf.reshootButton.hidden = true
                    strongSelf.currentColorView.backgroundColor = color
                    strongSelf.currentColorViewX.constant = point.x - strongSelf.currentColorView.frame.size.width / 2.0
                    strongSelf.currentColorViewY.constant = point.y - strongSelf.currentColorView.frame.size.height / 2.0
                }
            }
            })
    }
    
    func colorChosen(sender: AnyObject, color:Color) {
        self.selectedColor = color
        
        self.colorNameLabel.hidden = false
        self.colorCodeLabel.hidden = false
        self.favoritesButton.hidden = false
        self.visualizerButton.hidden = false
        
        self.primaryColorView.backgroundColor = color.uiColor
        self.colorNameLabel.text = "\(color.category.brand.name) - \(color.name)"
        self.colorCodeLabel.text = "#\(color.code)"
        self.favoritesButton.selected = FavoritesDatabase.sharedDatabase().isFavorite(color)
        
        self.favoritesButton.tintColor = isLightColor(color.uiColor) ? UIColor.blackColor() : UIColor.whiteColor()
        self.colorCodeLabel.textColor = self.favoritesButton.tintColor
    }
    
    //iPhone camera and library delegate methods
    
    //load an image into painter
    private func loadImage(image: UIImage!) {
        colorFinder.image = image
        
//        if let uicolors = colorFinder.getMostCommonColors(10, type: CBColorTypeAll) as? [UIColor] {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
//                let colors = self.findClosestMatches(uicolors)
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.swatchesCollection.swatchColors = colors
//                })
//            })
//        }
        
        //self.swatchesCollection.category
    }
    
    private func findClosestMatches(uicolors: [UIColor]) -> [Color] {
        
        let matches = NSMutableArray()
        uicolors.forEach({ (uicolor) -> () in
            //find closest match
            let match = Color.closestMatchForUIColor(uicolor, brand: nil, category: nil, excludingColors: matches as [AnyObject]);
            matches.addObject(match)
        })
        
        var colors: [Color] = []
    
        matches.forEach { (object) -> () in
            if let color = object as? Color {
                colors.append(color)
            }
        }
    
        return colors
    }
    
    @IBAction func reshootPressed(sender: AnyObject) {
        ImageManager.sharedInstance.getImage(self, type:.Camera, callback: { (image: UIImage?) -> Void in
            if let image = image {
                self.loadImage(image)
            }
        })
    }
   
    @IBAction func libraryButtonPressed(sender: AnyObject) {
        ImageManager.sharedInstance.getImage(self, type:.PhotoLibrary, callback: { (image: UIImage?) -> Void in
            if let image = image {
                self.loadImage(image)
            }
        })
    }
    
    @IBAction func favoritesPressed(sender: AnyObject) {
        if let color = selectedColor {
            let isFavorite = FavoritesDatabase.sharedDatabase().isFavorite(color)
            if isFavorite {
                FavoritesDatabase.sharedDatabase().removeFavorite(color)
            } else {
                FavoritesDatabase.sharedDatabase().addFavorite(color)
            }
            self.favoritesButton.selected = FavoritesDatabase.sharedDatabase().isFavorite(color)
        }
    }
    
    @IBAction func visualizerPressed(sender: AnyObject) {
        ImageManager.sharedInstance.proceedWithCameraAccess(self) {
            self.performSegueWithIdentifier("showPainter", sender: self)
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? AugmentedViewController {
            vc.selectedColor = selectedColor
        }
    }
}
