//
//  ColorDetails.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/14/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class ColorDetailsViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBOutlet weak var colorNameLabel: UILabel!
    @IBOutlet weak var colorCodeLabel: UILabel!
    @IBOutlet weak var primaryColorView: UIView!
    
    var selectedColor:Color!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up camera and library
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.navigationBar.hidden = false
        
        self.colorChosen(self, color:self.selectedColor)
    }
    
    func colorChosen(sender: AnyObject, color:Color) {
        self.selectedColor = color
        
        self.primaryColorView.backgroundColor = color.uiColor
        self.colorNameLabel.text = "\(color.category.brand.name) - \(color.name)"
        self.colorCodeLabel.text = "#\(color.code)"
        self.favoritesButton.selected = FavoritesDatabase.sharedDatabase().isFavorite(color)
        
        self.favoritesButton.tintColor = isLightColor(color.uiColor) ? UIColor.blackColor() : UIColor.whiteColor()
        self.closeButton.tintColor = self.favoritesButton.tintColor
        self.colorCodeLabel.textColor = self.favoritesButton.tintColor
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
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}
