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
        
        self.currentColorView.isHidden = true
        self.colorNameLabel.isHidden = true
        self.colorCodeLabel.isHidden = true
        self.favoritesButton.isHidden = true
        self.visualizerButton.isHidden = true
        
        self.reshootButton.isHidden = !ImageManager.sharedInstance.hasCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.navigationBar.isHidden = false
        
        //load an image if none yet
        if let _ = image {
            self.loadImage(image)
            self.image = nil
        }
        
        colorFinder.colorTouchedAtPoint = ({
            [weak self]
            (touchType: TouchStep, point:CGPoint, color:UIColor?) in
            
            if let strongSelf = self {
//                let pointInView = CGPoint(x:point.x + (self?.colorFinder.frame.origin.x)!,
//                    y:point.y + (self?.colorFinder.frame.origin.y)!)
                
                CBThreading.perform({ () -> Void in
                    if let dataColor = Color.closestMatch(for: color, brand: nil, category: nil, excludingColors: nil) {
                        DispatchQueue.main.async(execute: { () -> Void in
                            strongSelf.colorChosen(strongSelf, color: dataColor)
                        })
                    }
                    }, on: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), withIdentifier: "ColorFinder",
                       interval:1.0)
                
                if (touchType == TouchStepEnded) {
                    strongSelf.reshootButton.isHidden = !ImageManager.sharedInstance.hasCamera()
                    strongSelf.currentColorView.isHidden = false
                } else {
                    strongSelf.libraryButton.isHidden = true
                    strongSelf.reshootButton.isHidden = true
                    strongSelf.currentColorView.backgroundColor = color
                    strongSelf.currentColorViewX.constant = point.x - strongSelf.currentColorView.frame.size.width / 2.0
                    strongSelf.currentColorViewY.constant = point.y - strongSelf.currentColorView.frame.size.height / 2.0
                }
            }
            })
    }
    
    func colorChosen(_ sender: AnyObject, color:Color) {
        self.selectedColor = color
        
        self.colorNameLabel.isHidden = false
        self.colorCodeLabel.isHidden = false
        self.favoritesButton.isHidden = false
        self.visualizerButton.isHidden = false
        
        self.primaryColorView.backgroundColor = color.uiColor
        self.colorNameLabel.text = "\(color.category.brand.name) - \(color.name)"
        self.colorCodeLabel.text = "#\(color.code)"
        self.favoritesButton.isSelected = FavoritesDatabase.sharedDatabase().isFavorite(color)
        
        self.favoritesButton.tintColor = isLightColor(color.uiColor) ? UIColor.black : UIColor.white
        self.colorCodeLabel.textColor = self.favoritesButton.tintColor
    }
    
    //iPhone camera and library delegate methods
    
    //load an image into painter
    fileprivate func loadImage(_ image: UIImage!) {
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
    
    fileprivate func findClosestMatches(_ uicolors: [UIColor]) -> [Color] {
        
        let matches = NSMutableArray()
        uicolors.forEach({ (uicolor) -> () in
            //find closest match
            let match = Color.closestMatch(for: uicolor, brand: nil, category: nil, excludingColors: matches as [AnyObject]);
            matches.add(match)
        })
        
        var colors: [Color] = []
    
        matches.forEach { (object) -> () in
            if let color = object as? Color {
                colors.append(color)
            }
        }
    
        return colors
    }
    
    @IBAction func reshootPressed(_ sender: AnyObject) {
        ImageManager.sharedInstance.getImage(self, type:.camera, callback: { (image: UIImage?) -> Void in
            if let image = image {
                self.loadImage(image)
            }
        })
    }
   
    @IBAction func libraryButtonPressed(_ sender: AnyObject) {
        ImageManager.sharedInstance.getImage(self, type:.photoLibrary, callback: { (image: UIImage?) -> Void in
            if let image = image {
                self.loadImage(image)
            }
        })
    }
    
    @IBAction func favoritesPressed(_ sender: AnyObject) {
        if let color = selectedColor {
            let isFavorite = FavoritesDatabase.sharedDatabase().isFavorite(color)
            if isFavorite {
                FavoritesDatabase.sharedDatabase().removeFavorite(color)
            } else {
                FavoritesDatabase.sharedDatabase().addFavorite(color)
            }
            self.favoritesButton.isSelected = FavoritesDatabase.sharedDatabase().isFavorite(color)
        }
    }
    
    @IBAction func visualizerPressed(_ sender: AnyObject) {
        ImageManager.sharedInstance.proceedWithCameraAccess(self) {
            self.performSegue(withIdentifier: "showPainter", sender: self)
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AugmentedViewController {
            vc.selectedColor = selectedColor
        }
    }
}
