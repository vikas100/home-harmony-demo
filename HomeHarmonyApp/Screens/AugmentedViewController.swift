//
//  PainterViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/17/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

internal protocol ColorCategorySelectionDelegate : NSObjectProtocol {
    func categorySelected(_ sender: AnyObject, category:ColorCategory)
}

internal protocol ColorSelectionDelegate : NSObjectProtocol {
    func colorSelected(_ sender: AnyObject, color:Color)
    func colorChosen(_ sender: AnyObject, color:Color)
}

class AugmentedViewController: UIViewController, SidebarDelegate, ColorSelectionDelegate, PaletteDelegate, OptionCellDelegate, HSBColorPickerDelegate {
    
    internal var projectPath : String!
    internal var isSample = false
    
    fileprivate var initialXPosition : CGFloat = 0.0
    fileprivate var hasInitializedViews = false
    
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
    
    fileprivate var toolOptions = [Option]()
    fileprivate var lightingOptions = [Option]()
    fileprivate var rectangleOptions = [Option]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyPlainShadow(self.topButtons, offset:CGSize(width:0, height:3))
        applyPlainShadow(self.optionButtons, offset:CGSize(width:0, height:3))
        
        applyPlainShadow(self.primaryView, offset:CGSize(width:-10, height:0))
        applyPlainShadow(self.bottomButtons, offset:CGSize(width:0, height:-3))

        self.optionButtons.isHidden = true
        self.hsbPicker.delegate = self
        self.palette.delegate = self
        
        self.instructionsView.isHidden = true
        self.colorInfoButton.isHidden = true
        
        setupPainter()
        setupMenus()
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
            if let category = (CBCoreData.sharedInstance() as AnyObject).getFirstRecord(for: ColorCategory.classForCoder(),
                predicate: NSPredicate(format: "name==%@", INITIAL_COLOR_CATEGORY), sortedBy: nil, context: nil) as? ColorCategory {
                    DispatchQueue.main.async(execute: { () -> Void in
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
                strongSelf.undoButton.isEnabled = strongSelf.augmentedView.canStepBackward
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
                self.reshootButton.isHidden = true;
                self.libraryButton.isHidden = true;
            }
        }
        
        self.augmentedView.finishedToolBlock = {(toolMode: ToolMode) in
            self.openColorMenu(false)
            self.buttonVisibility()
            self.openSideMenu(false, completion: nil)
            
            self.clearAllButton.isEnabled = self.augmentedView.hasMadeChanges || self.isARMode
            
            //show final instructions
            if (!self.isARMode && !UserPreferences.sharedPreferences().hasSeenStillFinalInstructions) {
                UserPreferences.sharedPreferences().hasSeenStillFinalInstructions = true
                let delayTime = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.showFinalInstructions()
                }
            }
        }
    }
    
    var isShowingFinalInstructions = false
    func showFinalInstructions() {
        self.isShowingFinalInstructions = true
        self.instructionsView.isHidden = false
        self.instructionsSkipButton.isHidden = false
        
        self.instructionsLabel.text = NSLocalizedString("StillFinalInstructions", comment: "")
        
        let delayTime = DispatchTime.now() + Double(Int64(10.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.skipInstructions(self)
        }
    }
    
    @IBAction func skipInstructions(_ sender: AnyObject) {
        self.instructionsView.isHidden = true
        self.isShowingFinalInstructions = false
    }
    
    func setupMenus() {
        self.toolButton.setTitle(NSLocalizedString("Tool", comment: ""), for: UIControlState())
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (self.isPickingImage) {
            return;
        }
        
        self.navigationController?.navigationBar.isHidden = true
        
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
            self.augmentedView.paintColor = UIColor.clear
        }
        
        //wait for start
        self.captureButton.isHidden = true
        self.reshootButton.isHidden = true
        
        self.toolButton.isEnabled = false
        self.undoButton.isEnabled = false
        self.saveButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
                    self.instructionsView.isHidden = false
                    self.instructionsSkipButton.isHidden = true
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
        
        self.chooseColorMenu.frame.origin.y = self.bottomButtons.frame.minY
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.augmentedView.stopAugmentedReality()
        self.projectPath = nil
    }
    
    var isARMode = false
    func enableAR(_ isEnabled:Bool) {
        var isEnabled = isEnabled
        
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
                self.clearAllButton.isEnabled = false
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
            
            self.clearAllButton.isEnabled = self.augmentedView.hasMadeChanges
        }
    }
    
    func buttonVisibility() {
        
        self.captureButton.isHidden = !isARMode || !hasVideoCamera
        self.reshootButton.isHidden = isARMode || !hasVideoCamera
        
        self.toolButton.isEnabled = !isARMode
        self.undoButton.isEnabled = !isARMode && self.augmentedView.hasMadeChanges
        self.saveButton.isEnabled = !isARMode
        
        self.libraryButton.isHidden = false
    }
    
    // MARK: - Button Pressed
    @IBAction func exitPressed(_ sender: AnyObject) {
        if (!isARMode && self.augmentedView.hasMadeChanges) {
            let refreshAlert = UIAlertController(title: "Changes made", message: "Would you like to save your changes?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Save Changes", style: .default, handler: { (action: UIAlertAction!) in
                self.saveDialog(true)
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func clearAllPressed(_ sender: AnyObject) {
        self.augmentedView.clearAll()
        self.clearAllButton.isEnabled = false
    }
    
    @IBAction func undoButtonPressed(_ sender: AnyObject) {
        self.augmentedView.stepBackward()
    }
    
    @IBAction func sideMenuPressed(_ sender: AnyObject) {
        openSideMenu(self.primaryView.frame.origin.x < 10, completion: nil)
    }
    
    func openSideMenu(_ open:Bool, completion: (() -> Void)?) {
        let endPoint = open ?  self.sidebarView.frame.size.width : initialXPosition
        
        if (open) {
            self.openColorMenu(false)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.primaryViewXPosition.constant = endPoint
            self.primaryView.frame.origin.x = endPoint
            }, completion: { finished in
                if (completion != nil) {
                    completion!()
                }
        })
    }
    
    enum ColorMenu {
        case swatches, colorPicker, favorites
    }
    
    var isColorMenuOpen = false
    func openColorMenu(_ open:Bool, menu:ColorMenu?=nil) {
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
            self.colorLabelButton.isHidden = open
            self.colorLabel.isHidden = self.colorLabelButton.isHidden
        }
        
        let openPosition = self.bottomButtons.frame.minY - self.chooseColorMenu.frame.size.height
        let closedPositon = self.bottomButtons.frame.minY
        
        self.chooseColorMenu.isHidden = false
        
        if (!open) {
            self.swatchesViewTopWithBottomControlsTop.constant = 0
            self.bottomButtons.superview!.bringSubview(toFront: self.bottomButtons)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.chooseColorMenu.frame.origin.y = open ? openPosition : closedPositon
            }, completion: { finished in
                self.palette.getCurrentButton()?.isEditing = open
                if (open) {
                    self.swatchesViewTopWithBottomControlsTop.constant = self.chooseColorMenu.frame.size.height * -1
                    self.chooseColorMenu.superview!.bringSubview(toFront: self.chooseColorMenu)
                }
                self.chooseColorMenu.isHidden = !open
        })
    }
    
    @IBAction func showSwatches(_ sender: AnyObject) {
        if self.swatchesView.isHidden {
            showColorMenu(.swatches)
        } else {
            openColorMenu(false)
        }
    }
    
    @IBAction func showColorPicker(_ sender: AnyObject) {
        if self.hsbPicker.isHidden {
            showColorMenu(.colorPicker)
        } else {
            openColorMenu(false)
        }
    }
    
    @IBAction func showFavorites(_ sender: AnyObject) {
        if self.favoritesView.isHidden {
            showColorMenu(.favorites)
        } else {
            openColorMenu(false)
        }
    }
    
    func showColorMenu(_ menu:ColorMenu) {
        self.swatchesView.isHidden = true
        self.hsbPicker.isHidden = true
        self.favoritesView.isHidden = true
        
        if (self.palette.selectedColor != nil) {
            print("Selecting color in swatches: \(self.palette.selectedColor.name)");
        }
        
        switch menu {
        case .colorPicker:
            self.hsbPicker.isHidden = false
            break;
        case .swatches:
            self.swatchesCollection.selectColor(self.palette.selectedColor);
            self.swatchesView.isHidden = false
            break;
        case .favorites:
            self.favoritesCollection.selectColor(self.palette.selectedColor);
            self.favoritesView.isHidden = false
            break;
        }
    }

    @IBAction func toolPressed(_ sender: AnyObject) {
        self.displayOptions(self.toolOptions, selectedItem: Int(self.augmentedView.toolMode.rawValue))
    }
    
    @IBAction func capturePressed(_ sender: AnyObject) {
        let color = self.palette.selectedColor
        self.augmentedView.capture { () -> Void in
            self.enableAR(false)
            
            if let col = color {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.colorChosen(sender, color: col)
                })
            }
        }
    }
    
    @IBAction func reshootPressed(_ sender: AnyObject) {
        if (hasVideoCamera) {
            self.enableAR(true)
        }
    }
    
    @IBAction func savePressed(_ sender: AnyObject) {
        saveDialog(false)
    }
    
    func saveDialog(_ exit: Bool) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 2
        let saveProjectAction = UIAlertAction(title: "Save Project", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            let chooseNameAlert = UIAlertController(title: "Project Name", message: "Enter a name for this project", preferredStyle: UIAlertControllerStyle.alert)
            chooseNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler:  {
                (alert: UIAlertAction!) -> Void in
                var name = chooseNameAlert.textFields![0].text
                if (name!.characters.count == 0) {
                    name = "Project"
                }
                
                ProjectDatabase.sharedDatabase().saveProject(self.augmentedView, name:name!)
                
                self.augmentedView.hasMadeChanges = false
                
                if (exit) {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            chooseNameAlert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter Project Name:"
                textField.autocapitalizationType = UITextAutocapitalizationType.words
                if let project = ProjectDatabase.sharedDatabase()[self.augmentedView.projectID] as? Project {
                    textField.text = project.name
                }
            })
            
            chooseNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            
            self.present(chooseNameAlert, animated: true, completion: nil)
        })
        let saveAction = UIAlertAction(title: "Save Image", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Saved")
            self.augmentedView.hasMadeChanges = false
            
            if let imageToSave = self.augmentedView.getRenderedImage()
            {
                UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
                
                let alert = UIAlertController(title: "Image Saved", message: "Image was saved to camera roll", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil));
                self.present(alert, animated: true, completion: nil)
                
                if (exit) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        // 4
        optionMenu.addAction(saveProjectAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        presentActionSheet(optionMenu, viewController: self)
    }
    
    func setColorCategory(_ category:ColorCategory) {
        self.swatchesCollection.category = category
        self.swatchesButton.setTitle(category.name, for: UIControlState())
    }
    
    func categorySelected(_ sender: AnyObject, category:ColorCategory) {
        setColorCategory(category)
        
        self.openSideMenu(false, completion: {
            self.openColorMenu(true, menu: .swatches)
        })
    }
    
    func colorChosen(_ sender: AnyObject, color:Color) {
        
        self.openSideMenu(false, completion: nil)
        if (self.augmentedView.toolMode == ToolModeEraser) {
            self.handleToolModeOption(self.toolOptions[0])
        }
        self.augmentedView.paintColor = color.uiColor
        self.colorLabelButton.isHidden = false
        self.colorLabel.isHidden = false
        self.colorLabel.text = color.name;
        
        if (self.swatchesCollection.category != color.category) {
            setColorCategory(color.category)
        }
        
        self.palette.selectedColor = color
        self.colorInfoButton.isHidden = false
        
        
        if (sender as? UIView != self.hsbPicker) {
            let position = self.hsbPicker.getPointForColor(color.uiColor)
            colorPickerMarker.backgroundColor = color.uiColor
            colorPickerMarkerX.constant = position.x - colorPickerMarker.bounds.width / 2.0
            colorPickerMarkerY.constant = position.y - colorPickerMarker.bounds.height / 2.0
        }
        
        if (!UserPreferences.sharedPreferences().hasSeenColorInstructions) {
            UserPreferences.sharedPreferences().hasSeenColorInstructions = true
            self.instructionsView.isHidden = false
            
            if (!UserPreferences.sharedPreferences().hasSeenTouchInstructions) {
                UserPreferences.sharedPreferences().hasSeenTouchInstructions = true
                if (self.isARMode) {
                    self.instructionsLabel.text = NSLocalizedString("ARTouchWallInstructions", comment: "")
                } else {
                    self.instructionsLabel.text = NSLocalizedString("StillTouchWallInstructions", comment: "")
                }
                
                self.openColorMenu(false)
                let delayTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.instructionsView.isHidden = true
                }
            }
        }
    }
    
    func colorSelected(_ sender: AnyObject, color:Color) {
        //print("Color selected")
    }
    
    @IBAction func colorLabelButtonPressed(_ sender: AnyObject) {
        if (self.palette.selectedColor == nil) {
            self.openColorMenu(true, menu: .swatches)
        } else {
            self.performSegue(withIdentifier: "showColorDetails", sender: self)
        }
    }
    
    @IBAction func libraryButtonPressed(_ sender: AnyObject) {
        
        if let image = sender as? UIImage {
            self.augmentedView.load(image, hasAlphaMasking: false)
            self.enableAR(false)
            self.isPickingImage = true
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SidebarTableViewController {
            vc.delegate = self
        } else if let vc = segue.destination as? SwatchCollectionViewController {
            swatchesCollection = vc
            vc.delegate = self
        } else if let vc = segue.destination as? FavoritesCollectionViewController {
            favoritesCollection = vc
            vc.delegate = self
        } else if let vc = segue.destination as? OptionsCollectionViewController {
            optionsMenu = vc
            vc.delegate = self
        } else if let vc = segue.destination as? ColorDetailsViewController {
            vc.selectedColor = self.palette.selectedColor
        }
    }
    
    // MARK: - Palette delegates
    func paletteColorPressed(_ sender: PaletteButton, index:Int) {
        if (sender.isGhost) {
            self.augmentedView.appendNewLayer()
            self.augmentedView.editLayerIndex = self.augmentedView.layerCount - 1
            sender.isGhost = false
            self.swatchesCollection.deselectAll()
            openColorMenu(true, menu: .swatches)
        }
        else {
            let newEditLayerIndex = Int32(index + 1)
            if (!self.augmentedView.isShowingAugmentedReality && newEditLayerIndex != self.augmentedView.editLayerIndex) {
                self.augmentedView.editLayerIndex = Int32(index + 1)
                self.colorChosen(sender, color: self.palette.selectedColor)
                openColorMenu(true, menu: .swatches)
            } else {
                openColorMenu(!isColorMenuOpen, menu: .swatches)
            }
        }
    }
    
    func paletteFrameUpdated(_ frame:CGRect) {
        paletteWidth.constant = frame.size.width
    }
    
    var currentOptions:[Option]!
    func displayOptions(_ options:[Option], selectedItem:Int) {
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
        self.optionButtons.isHidden = false
    }
    
    func hideOptions() {
        self.optionButtons.isHidden = true
        currentOptions = nil
    }
    
    func isShowingOptions(_ options:[Option]) -> Bool {
        return currentOptions != nil && currentOptions[0].title == options[0].title
    }
    
    func optionsCanceled(_ options:[Option]) {
        if (isShowingOptions(rectangleOptions)) {
            self.augmentedView.decommitChanges()
        }
    }
    
    func optionSelected(_ option:Option) {
        if (isShowingOptions(toolOptions)) {
            handleToolModeOption(option)
        } else if (isShowingOptions(lightingOptions)) {
            handleLightingOption(option)
        } else if (isShowingOptions(rectangleOptions)) {
            handleRectangleOption(option)
        }
    }
    
    func handleToolModeOption(_ option:Option) {
        if (option.id == 4) {
            //lighting
            displayOptions(self.lightingOptions, selectedItem: Int(self.augmentedView.simulatedLighting.rawValue))
        } else {
            hideOptions()
            self.toolButton.setImage(option.image, for: UIControlState())
            self.augmentedView.toolMode = ToolMode(UInt32(option.id))
        }
    }
    
    func handleLightingOption(_ option:Option) {
        self.augmentedView.simulatedLighting = LightingType(UInt32(option.id))
        hideOptions()
    }
    
    func handleRectangleOption(_ option:Option) {
        if (option.id == 0) {
            self.augmentedView.commitChanges()
        } else {
            self.augmentedView.decommitChanges()
        }
        hideOptions()
    }
    
    //MARK: - Color picker
    func HSBColorColorPickerTouched(_ sender:HSBColorPicker, color:UIColor, point:CGPoint, state:UIGestureRecognizerState) {
        
        colorPickerMarker.backgroundColor = color
        colorPickerMarkerX.constant = point.x - colorPickerMarker.bounds.width / 2.0
        colorPickerMarkerY.constant = point.y - colorPickerMarker.bounds.height / 2.0
        
        CBThreading.perform({ () -> Void in
            if let dataColor = Color.closestMatch(for: color, brand: nil, category: nil, excludingColors: nil) {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.colorChosen(sender, color: dataColor)
                })
            }
            }, on: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), withIdentifier: "HSBColorColorPickerTouched", interval:0.25)
    }
}
