//
//  PainterViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/17/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

internal protocol ColorCategorySelectionDelegate : NSObjectProtocol {
    func categorySelected(sender: AnyObject, category:ColorCategory)
}

internal protocol ColorSelectionDelegate : NSObjectProtocol {
    func colorSelected(sender: AnyObject, color:Color)
    func colorChosen(sender: AnyObject, color:Color)
}

class AugmentedViewController: UIViewController, SidebarDelegate, ColorSelectionDelegate, PaletteDelegate, OptionCellDelegate, HSBColorPickerDelegate {
    
    internal var projectPath : String!
    internal var isSample = false
    
    private var initialXPosition : CGFloat = 0.0
    private var hasInitializedViews = false
    
    var selectedColor:Color!
    
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsSkipButton: UIButton!
    
    @IBOutlet weak var topButtons: UIView!
    @IBOutlet weak var optionButtons: UIView!
    
    @IBOutlet weak var bottomButtons: UIView!
    @IBOutlet weak var palette: Palette!
    @IBOutlet weak var paletteWidth: NSLayoutConstraint!
    @IBOutlet weak var sidebarView: UIView!
    @IBOutlet weak var primaryViewXPosition: NSLayoutConstraint!
    @IBOutlet weak var primaryView: UIView!
    @IBOutlet weak var sideMenuButton: UIButton!
    
    @IBOutlet weak var chooseColorMenu: UIView!
    @IBOutlet weak var swatchesViewTopWithBottomControlsTop: NSLayoutConstraint!
    @IBOutlet weak var hsbPicker: HSBColorPicker!
    @IBOutlet weak var swatchesView: UIView!
    @IBOutlet weak var favoritesView: UIView!
    
    @IBOutlet weak var swatchesButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBOutlet weak var augmentedView: CBCombinedPainter!
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var reshootButton: UIButton!
    @IBOutlet weak var libraryButton: LibraryThumbnailButton!
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var toolButton: UIButton!
    
    @IBOutlet weak var colorLabelButton: UIButton!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorInfoButton: UIButton!
    
    
    @IBOutlet weak var colorPickerMarker:UIView!
    @IBOutlet var colorPickerMarkerX: NSLayoutConstraint!
    @IBOutlet var colorPickerMarkerY: NSLayoutConstraint!
    
    var hasVideoCamera = false
    var optionsMenu: OptionsCollectionViewController!;
    
    var isPickingImage = false
    var swatchesCollection:SwatchCollectionViewController!
    var favoritesCollection:FavoritesCollectionViewController!
    
    private var toolOptions = [Option]()
    private var lightingOptions = [Option]()
    private var rectangleOptions = [Option]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyPlainShadow(self.topButtons, offset:CGSize(width:0, height:3))
        applyPlainShadow(self.optionButtons, offset:CGSize(width:0, height:3))
        
        applyPlainShadow(self.primaryView, offset:CGSize(width:-10, height:0))
        applyPlainShadow(self.bottomButtons, offset:CGSize(width:0, height:-3))

        self.optionButtons.hidden = true
        self.hsbPicker.delegate = self
        self.palette.delegate = self
        
        self.instructionsView.hidden = true
        self.colorInfoButton.hidden = true
        
        setupPainter()
        setupMenus()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if let category = CBCoreData.sharedInstance().getFirstRecordForClass(ColorCategory.classForCoder(),
                predicate: NSPredicate(format: "name==%@", INITIAL_COLOR_CATEGORY), sortedBy: nil, context: nil) as? ColorCategory {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.setColorCategory(category)
                    })
            }
        }
    }
    
    func setupPainter() {
        self.palette.painter = self.augmentedView
        
        self.augmentedView.toolMode = ToolModePaintbrush
        self.augmentedView.historyChangedBlock = ({[weak self] in
            if let strongSelf = self {
                strongSelf.undoButton.enabled = strongSelf.augmentedView.canStepBackward
                let shouldHaveGhost = strongSelf.augmentedView.stillImage.topLayer.hasMadeChangesInMask
                if (!shouldHaveGhost) {
                    strongSelf.palette.removeGhosts()
                }
                else if (strongSelf.palette.getGhostButton() == nil && strongSelf.augmentedView.layerCount < 4) {
                    strongSelf.palette.appendButton().isGhost = true
                }
                strongSelf.openColorMenu(false)
            }
            })
        
        self.augmentedView.startedToolBlock = { (toolMode) -> (Void) in
            self.openColorMenu(false)
            if (toolMode == ToolModeRectangle) {
                self.displayOptions(self.rectangleOptions, selectedItem: -1)
            } else {
                self.reshootButton.hidden = true;
                self.libraryButton.hidden = true;
            }
        }
        
        self.augmentedView.finishedToolBlock = {(toolMode: ToolMode) in
            self.openColorMenu(false)
            self.buttonVisibility()
            self.openSideMenu(false, completion: nil)
            
            self.clearAllButton.enabled = self.augmentedView.hasMadeChanges || self.isARMode
            
            //show final instructions
            if (!self.isARMode && !UserPreferences.sharedPreferences().hasSeenStillFinalInstructions) {
                UserPreferences.sharedPreferences().hasSeenStillFinalInstructions = true
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.showFinalInstructions()
                }
            }
        }
    }
    
    var isShowingFinalInstructions = false
    func showFinalInstructions() {
        self.isShowingFinalInstructions = true
        self.instructionsView.hidden = false
        self.instructionsSkipButton.hidden = false
        
        self.instructionsLabel.text = NSLocalizedString("StillFinalInstructions", comment: "")
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.skipInstructions(self)
        }
    }
    
    @IBAction func skipInstructions(sender: AnyObject) {
        self.instructionsView.hidden = true
        self.isShowingFinalInstructions = false
    }
    
    func setupMenus() {
        self.toolButton.setTitle(NSLocalizedString("Tool", comment: ""), forState: UIControlState.Normal)
        
        self.toolOptions.append(Option(id: Int(ToolModePaintbrush.rawValue), title: NSLocalizedString("Paint", comment: ""),
            image: UIImage(named: "PaintButton")!, minWidth:70))
        self.toolOptions.append(Option(id: Int(ToolModeEraser.rawValue), title: NSLocalizedString("Eraser", comment: ""),
            image: UIImage(named: "EraserButton")!,minWidth:80))
        self.toolOptions.append(Option(id: 4, title: NSLocalizedString("Lighting", comment: ""),
            image: UIImage(named: "LightingButton")!, minWidth:100))
        self.toolOptions.append(Option(id: Int(ToolModeRectangle.rawValue), title: NSLocalizedString("Square", comment: ""),
            image: UIImage(named: "RectangleButton")!, minWidth:90))
        
        self.lightingOptions.append(Option(id: Int(LightingTypeNone.rawValue), title: NSLocalizedString("None", comment: ""),
            image: nil, minWidth:60))
        self.lightingOptions.append(Option(id: Int(LightingTypeIncandescent.rawValue), title: NSLocalizedString("Incandescent", comment: ""),
            image: nil,minWidth:110))
        self.lightingOptions.append(Option(id: Int(LightingTypeLEDWarm.rawValue), title: NSLocalizedString("LED Warm", comment: ""),
            image: nil, minWidth:90))
        self.lightingOptions.append(Option(id: Int(LightingTypeLEDWhite.rawValue), title: NSLocalizedString("LED White", comment: ""),
            image: nil, minWidth:90))
        self.lightingOptions.append(Option(id: Int(LightingTypeLEDWhite.rawValue), title: NSLocalizedString("Fluorescent", comment: ""),
            image: nil, minWidth:110))
        
        self.rectangleOptions.append(Option(id: Int(LightingTypeNone.rawValue), title: NSLocalizedString("Apply Rectangle", comment: ""),
            image: nil, minWidth:140))
        
        self.rectangleOptions.append(Option(id: Int(LightingTypeNone.rawValue), title: NSLocalizedString("Do not Apply", comment: ""),
            image: nil, minWidth:140))
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if (self.isPickingImage) {
            return;
        }
        
        self.navigationController?.navigationBar.hidden = true
        
        hasVideoCamera = ImageManager.sharedInstance.hasCamera()
        
        if (self.projectPath != nil || !hasVideoCamera) {
            isARMode = false
            self.augmentedView.loadProject(nil, fromDirectory: self.projectPath)
            
            if (isSample) {
                self.augmentedView.clearAll()
                self.augmentedView.allowColorAdjustment = false
            }
        }
        else {
            isARMode = true
            self.augmentedView.paintColor = UIColor.clearColor()
        }
        
        //wait for start
        self.captureButton.hidden = true
        self.reshootButton.hidden = true
        
        self.toolButton.enabled = false
        self.undoButton.enabled = false
        self.saveButton.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        if (self.isPickingImage) {
            self.isPickingImage = false
            return;
        }
        
        enableAR(isARMode)
        
        if (!hasInitializedViews) {
            if (!ImageManager.sharedInstance.hasCamera() && self.augmentedView.previewImage == nil) {
                libraryButton.openLibrary()
            } else {
                if (!UserPreferences.sharedPreferences().hasSeenColorInstructions) {
                    self.instructionsView.hidden = false
                    self.instructionsSkipButton.hidden = true
                    self.instructionsLabel.text = NSLocalizedString("ChooseColorInstructions", comment: "")
                }
            }
        }
        
        hasInitializedViews = true
    }
    
    override func viewDidLayoutSubviews() {
        if (hasInitializedViews) {
            return
        }
        
        initialXPosition = self.primaryView.frame.origin.x
        
        self.chooseColorMenu.frame.origin.y = CGRectGetMinY(self.bottomButtons.frame)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.augmentedView.stopAugmentedReality()
        self.projectPath = nil
    }
    
    var isARMode = false
    func enableAR(var isEnabled:Bool) {
        
        if (!hasVideoCamera && isEnabled) {
            isEnabled = false
        }
        
        isARMode = isEnabled
        self.buttonVisibility()
                
        if (isEnabled) {
            ImageManager.sharedInstance.proceedWithCameraAccess(self, handler: {
                //Gained camera access
                self.augmentedView.showAugmentedReality()
                self.palette.sync()
                if let color = self.palette.selectedColor {
                    self.colorChosen(self, color: color)
                }
                self.clearAllButton.enabled = false
                if let color = self.selectedColor {
                    self.colorChosen(self, color: color)
                    self.selectedColor = nil
                }
            })
        } else {
            self.augmentedView.showImagePainter()
            self.palette.sync()
            
            if (self.augmentedView.layerCount > 0) {
                if let color = self.selectedColor {
                    self.colorChosen(self, color: color)
                    self.selectedColor = nil
                }
                else if let color = self.palette.selectedColor {
                    self.colorChosen(self, color: color)
                }
            }
            
            self.clearAllButton.enabled = self.augmentedView.hasMadeChanges
        }
    }
    
    func buttonVisibility() {
        
        self.captureButton.hidden = !isARMode || !hasVideoCamera
        self.reshootButton.hidden = isARMode || !hasVideoCamera
        
        self.toolButton.enabled = !isARMode
        self.undoButton.enabled = !isARMode && self.augmentedView.hasMadeChanges
        self.saveButton.enabled = !isARMode
        
        self.libraryButton.hidden = false
    }
    
    // MARK: - Button Pressed
    @IBAction func exitPressed(sender: AnyObject) {
        if (!isARMode && self.augmentedView.hasMadeChanges) {
            let refreshAlert = UIAlertController(title: "Changes made", message: "Would you like to save your changes?", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Save Changes", style: .Default, handler: { (action: UIAlertAction!) in
                self.saveDialog(true)
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func clearAllPressed(sender: AnyObject) {
        self.augmentedView.clearAll()
        self.clearAllButton.enabled = false
    }
    
    @IBAction func undoButtonPressed(sender: AnyObject) {
        self.augmentedView.stepBackward()
    }
    
    @IBAction func sideMenuPressed(sender: AnyObject) {
        openSideMenu(self.primaryView.frame.origin.x < 10, completion: nil)
    }
    
    func openSideMenu(open:Bool, completion: (() -> Void)?) {
        let endPoint = open ?  self.sidebarView.frame.size.width : initialXPosition
        
        if (open) {
            self.openColorMenu(false)
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.primaryViewXPosition.constant = endPoint
            self.primaryView.frame.origin.x = endPoint
            }, completion: { finished in
                if (completion != nil) {
                    completion!()
                }
        })
    }
    
    enum ColorMenu {
        case Swatches, ColorPicker, Favorites
    }
    
    var isColorMenuOpen = false
    func openColorMenu(open:Bool, menu:ColorMenu?=nil) {
        if let menu = menu {
            if (open) {
                showColorMenu(menu)
            }
        }
        
        if (open == isColorMenuOpen) {
            return
        }
        isColorMenuOpen = open
        
        if (self.palette.selectedColor == nil) {
            self.colorLabelButton.hidden = open
            self.colorLabel.hidden = self.colorLabelButton.hidden
        }
        
        let openPosition = CGRectGetMinY(self.bottomButtons.frame) - self.chooseColorMenu.frame.size.height
        let closedPositon = CGRectGetMinY(self.bottomButtons.frame)
        
        self.chooseColorMenu.hidden = false
        
        if (!open) {
            self.swatchesViewTopWithBottomControlsTop.constant = 0
            self.bottomButtons.superview!.bringSubviewToFront(self.bottomButtons)
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.chooseColorMenu.frame.origin.y = open ? openPosition : closedPositon
            }, completion: { finished in
                self.palette.getCurrentButton()?.isEditing = open
                if (open) {
                    self.swatchesViewTopWithBottomControlsTop.constant = self.chooseColorMenu.frame.size.height * -1
                    self.chooseColorMenu.superview!.bringSubviewToFront(self.chooseColorMenu)
                }
                self.chooseColorMenu.hidden = !open
        })
    }
    
    @IBAction func showSwatches(sender: AnyObject) {
        if self.swatchesView.hidden {
            showColorMenu(.Swatches)
        } else {
            openColorMenu(false)
        }
    }
    
    @IBAction func showColorPicker(sender: AnyObject) {
        if self.hsbPicker.hidden {
            showColorMenu(.ColorPicker)
        } else {
            openColorMenu(false)
        }
    }
    
    @IBAction func showFavorites(sender: AnyObject) {
        if self.favoritesView.hidden {
            showColorMenu(.Favorites)
        } else {
            openColorMenu(false)
        }
    }
    
    func showColorMenu(menu:ColorMenu) {
        self.swatchesView.hidden = true
        self.hsbPicker.hidden = true
        self.favoritesView.hidden = true
        
        if (self.palette.selectedColor != nil) {
            print("Selecting color in swatches: \(self.palette.selectedColor.name)");
        }
        
        switch menu {
        case .ColorPicker:
            self.hsbPicker.hidden = false
            break;
        case .Swatches:
            self.swatchesCollection.selectColor(self.palette.selectedColor);
            self.swatchesView.hidden = false
            break;
        case .Favorites:
            self.favoritesCollection.selectColor(self.palette.selectedColor);
            self.favoritesView.hidden = false
            break;
        }
    }

    @IBAction func toolPressed(sender: AnyObject) {
        self.displayOptions(self.toolOptions, selectedItem: Int(self.augmentedView.toolMode.rawValue))
    }
    
    @IBAction func capturePressed(sender: AnyObject) {
        let color = self.palette.selectedColor
        self.augmentedView.captureToImagePainter { () -> Void in
            self.enableAR(false)
            
            if let col = color {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.colorChosen(sender, color: col)
                })
            }
        }
    }
    
    @IBAction func reshootPressed(sender: AnyObject) {
        if (hasVideoCamera) {
            self.enableAR(true)
        }
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        saveDialog(false)
    }
    
    func saveDialog(exit: Bool) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let saveProjectAction = UIAlertAction(title: "Save Project", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            let chooseNameAlert = UIAlertController(title: "Project Name", message: "Enter a name for this project", preferredStyle: UIAlertControllerStyle.Alert)
            chooseNameAlert.addAction(UIAlertAction(title: "Save", style: .Default, handler:  {
                (alert: UIAlertAction!) -> Void in
                var name = chooseNameAlert.textFields![0].text
                if (name!.characters.count == 0) {
                    name = "Project"
                }
                
                ProjectDatabase.sharedDatabase().saveProject(self.augmentedView, name:name!)
                
                self.augmentedView.hasMadeChanges = false
                
                if (exit) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }))
            chooseNameAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Enter Project Name:"
                textField.autocapitalizationType = UITextAutocapitalizationType.Words
                if let project = ProjectDatabase.sharedDatabase()[self.augmentedView.projectID] as? Project {
                    textField.text = project.name
                }
            })
            
            chooseNameAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:nil))
            
            self.presentViewController(chooseNameAlert, animated: true, completion: nil)
        })
        let saveAction = UIAlertAction(title: "Save Image", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Saved")
            self.augmentedView.hasMadeChanges = false
            
            if let imageToSave = self.augmentedView.getRenderedImage()
            {
                UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
                
                let alert = UIAlertController(title: "Image Saved", message: "Image was saved to camera roll", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
                self.presentViewController(alert, animated: true, completion: nil)
                
                if (exit) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        // 4
        optionMenu.addAction(saveProjectAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        presentActionSheet(optionMenu, viewController: self)
    }
    
    func setColorCategory(category:ColorCategory) {
        self.swatchesCollection.category = category
        self.swatchesButton.setTitle(category.name, forState: UIControlState.Normal)
    }
    
    func categorySelected(sender: AnyObject, category:ColorCategory) {
        setColorCategory(category)
        
        self.openSideMenu(false, completion: {
            self.openColorMenu(true, menu: .Swatches)
        })
    }
    
    func colorChosen(sender: AnyObject, color:Color) {
        
        self.openSideMenu(false, completion: nil)
        if (self.augmentedView.toolMode == ToolModeEraser) {
            self.handleToolModeOption(self.toolOptions[0])
        }
        self.augmentedView.paintColor = color.uiColor
        self.colorLabelButton.hidden = false
        self.colorLabel.hidden = false
        self.colorLabel.text = color.name;
        
        if (self.swatchesCollection.category != color.category) {
            setColorCategory(color.category)
        }
        
        self.palette.selectedColor = color
        self.colorInfoButton.hidden = false
        
        
        if (sender as? UIView != self.hsbPicker) {
            let position = self.hsbPicker.getPointForColor(color.uiColor)
            colorPickerMarker.backgroundColor = color.uiColor
            colorPickerMarkerX.constant = position.x - colorPickerMarker.bounds.width / 2.0
            colorPickerMarkerY.constant = position.y - colorPickerMarker.bounds.height / 2.0
        }
        
        if (!UserPreferences.sharedPreferences().hasSeenColorInstructions) {
            UserPreferences.sharedPreferences().hasSeenColorInstructions = true
            self.instructionsView.hidden = false
            
            if (!UserPreferences.sharedPreferences().hasSeenTouchInstructions) {
                UserPreferences.sharedPreferences().hasSeenTouchInstructions = true
                if (self.isARMode) {
                    self.instructionsLabel.text = NSLocalizedString("ARTouchWallInstructions", comment: "")
                } else {
                    self.instructionsLabel.text = NSLocalizedString("StillTouchWallInstructions", comment: "")
                }
                
                self.openColorMenu(false)
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.instructionsView.hidden = true
                }
            }
        }
    }
    
    func colorSelected(sender: AnyObject, color:Color) {
        //print("Color selected")
    }
    
    @IBAction func colorLabelButtonPressed(sender: AnyObject) {
        if (self.palette.selectedColor == nil) {
            self.openColorMenu(true, menu: .Swatches)
        } else {
            self.performSegueWithIdentifier("showColorDetails", sender: self)
        }
    }
    
    @IBAction func libraryButtonPressed(sender: AnyObject) {
        
        if let image = sender as? UIImage {
            self.augmentedView.loadImage(image, hasAlphaMasking: false)
            self.enableAR(false)
            self.isPickingImage = true
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SidebarTableViewController {
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? SwatchCollectionViewController {
            swatchesCollection = vc
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? FavoritesCollectionViewController {
            favoritesCollection = vc
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? OptionsCollectionViewController {
            optionsMenu = vc
            vc.delegate = self
        } else if let vc = segue.destinationViewController as? ColorDetailsViewController {
            vc.selectedColor = self.palette.selectedColor
        }
    }
    
    // MARK: - Palette delegates
    func paletteColorPressed(sender: PaletteButton, index:Int) {
        if (sender.isGhost) {
            self.augmentedView.appendNewLayer()
            self.augmentedView.editLayerIndex = self.augmentedView.layerCount - 1
            sender.isGhost = false
            self.swatchesCollection.deselectAll()
            openColorMenu(true, menu: .Swatches)
        }
        else {
            let newEditLayerIndex = Int32(index + 1)
            if (!self.augmentedView.isShowingAugmentedReality && newEditLayerIndex != self.augmentedView.editLayerIndex) {
                self.augmentedView.editLayerIndex = Int32(index + 1)
                self.colorChosen(sender, color: self.palette.selectedColor)
                openColorMenu(true, menu: .Swatches)
            } else {
                openColorMenu(!isColorMenuOpen, menu: .Swatches)
            }
        }
    }
    
    func paletteFrameUpdated(frame:CGRect) {
        paletteWidth.constant = frame.size.width
    }
    
    var currentOptions:[Option]!
    func displayOptions(options:[Option], selectedItem:Int) {
        if (isShowingOptions(options)) {
            optionsCanceled(options)
            hideOptions()
            return;
        }
        options.forEach{ $0.enabled = selectedItem != $0.id }
        
        if (currentOptions != nil) {
            optionsCanceled(currentOptions)
        }
        
        currentOptions = options
        self.optionsMenu.loadOptions(options)
        self.optionButtons.hidden = false
    }
    
    func hideOptions() {
        self.optionButtons.hidden = true
        currentOptions = nil
    }
    
    func isShowingOptions(options:[Option]) -> Bool {
        return currentOptions != nil && currentOptions[0].title == options[0].title
    }
    
    func optionsCanceled(options:[Option]) {
        if (isShowingOptions(rectangleOptions)) {
            self.augmentedView.decommitChanges()
        }
    }
    
    func optionSelected(option:Option) {
        if (isShowingOptions(toolOptions)) {
            handleToolModeOption(option)
        } else if (isShowingOptions(lightingOptions)) {
            handleLightingOption(option)
        } else if (isShowingOptions(rectangleOptions)) {
            handleRectangleOption(option)
        }
    }
    
    func handleToolModeOption(option:Option) {
        if (option.id == 4) {
            //lighting
            displayOptions(self.lightingOptions, selectedItem: Int(self.augmentedView.simulatedLighting.rawValue))
        } else {
            hideOptions()
            self.toolButton.setImage(option.image, forState: UIControlState.Normal)
            self.augmentedView.toolMode = ToolMode(UInt32(option.id))
        }
    }
    
    func handleLightingOption(option:Option) {
        self.augmentedView.simulatedLighting = LightingType(UInt32(option.id))
        hideOptions()
    }
    
    func handleRectangleOption(option:Option) {
        if (option.id == 0) {
            self.augmentedView.commitChanges()
        } else {
            self.augmentedView.decommitChanges()
        }
        hideOptions()
    }
    
    //MARK: - Color picker
    func HSBColorColorPickerTouched(sender:HSBColorPicker, color:UIColor, point:CGPoint, state:UIGestureRecognizerState) {
        
        colorPickerMarker.backgroundColor = color
        colorPickerMarkerX.constant = point.x - colorPickerMarker.bounds.width / 2.0
        colorPickerMarkerY.constant = point.y - colorPickerMarker.bounds.height / 2.0
        
        CBThreading.performBlock({ () -> Void in
            if let dataColor = Color.closestMatchForUIColor(color, brand: nil, category: nil, excludingColors: nil) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.colorChosen(sender, color: dataColor)
                })
            }
            }, onQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), withIdentifier: "HSBColorColorPickerTouched", interval:0.25)
    }
}
