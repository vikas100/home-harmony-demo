//
//  Palette.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/3/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

internal protocol PaletteDelegate : NSObjectProtocol {
    func paletteColorPressed(_ sender: PaletteButton, index:Int)
    func paletteFrameUpdated(_ frame:CGRect)
}

@IBDesignable
class Palette: UIView {
    
    weak internal var delegate: PaletteDelegate?
    weak internal var selectedButton: PaletteButton?
    weak internal var painter:CBCombinedPainter?
    
    fileprivate var buttonSize:CGSize!
    
    fileprivate func initialize() {
        buttonSize = CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func sync() {
        subviews.forEach{ $0.removeFromSuperview() }
        
        if let painter = self.painter {
            if (painter.isShowingAugmentedReality) {
                let button = appendButton()
                button.isCurrentLayer = true
                button.backgroundColor = painter.paintColor
            } else if (painter.layerCount > 0) {
                for index in 1...painter.layerCount-1 {
                    let color = painter.stillImage.layer(at: index).fillColor
                    let components = (color?.cgColor)?.components
                    let button = appendButton()
                    if (components?[3] == 0) {
                        button.backgroundColor = self.tintColor
                    } else {
                        button.backgroundColor = color
                    }
                    if (index == painter.editLayerIndex) {
                        button.isCurrentLayer = true
                    }
                }
                if (painter.stillImage.topLayer.hasMadeChangesInMask && painter.layerCount < 4) {
                    appendButton().isGhost = true
                }
            }
        }
    }
    
    var _lastSelectedColor:Color!
    var selectedColor:Color! {
        get {
            if let painter = self.painter {
                if (painter.isShowingAugmentedReality) {
                    return _lastSelectedColor
                } else if let layer = painter.editLayer {
                    if let userData = layer.userData {
                        if let colorID = userData["colorId"] as? String {
                            let url = URL(string: colorID)
                            let object = (CBCoreData.sharedInstance() as AnyObject).getObjectWith(url)
                            return object as? Color
                        }
                    }
                }
            }
            return nil
        }
        set {
            _lastSelectedColor = newValue
            self.getCurrentButton()?.backgroundColor = newValue?.uiColor
            self.getGhostButton()?.backgroundColor = newValue?.uiColor
            
            if let painter = self.painter {
                if (painter.isShowingAugmentedReality) {
                    _lastSelectedColor = newValue
                } else if let layer = painter.editLayer {
                    if let userData = layer.userData {
                        if (newValue == nil) {
                            userData.removeObject(forKey: "colorId")
                        } else {
                            userData["colorId"] = String(describing: newValue.objectID.uriRepresentation().absoluteURL)
                        }
                    }
                }
            }
        }
    }
    
    func getCurrentButton() -> PaletteButton? {
        if let painter = self.painter {
            let index = painter.isShowingAugmentedReality ? 0 : Int(painter.editLayerIndex - 1)
            return self.getButtonAtIndex(index)
        }
        return nil
    }
    
    // MARK: - Public Methods
    func getButtonAtIndex(_ index:Int) -> PaletteButton? {
        if (index >= 0 && index < self.subviews.count) {
            if let button = self.subviews[self.subviews.count - index - 1] as? PaletteButton {
                return button
            }
        }
        return nil
    }
    
    func getGhostButton() -> PaletteButton? {
        let index = self.subviews.count - 1;
        if let button = getButtonAtIndex(index) {
            if (button.isGhost) {
                return button
            }
        }
        return nil
    }
    
    func removeGhosts() {
        let index = self.subviews.count - 1;
        if let button = getButtonAtIndex(index) {
            if (button.isGhost) {
                removeButtonAtIndex(index)
            }
        }
    }
    
    func appendButton() -> PaletteButton {
        
        if let superview = self.superview {
            buttonSize.width = fmin(buttonSize.width, superview.frame.size.width / 5.0)
        }
        
        let newButton = PaletteButton(type: UIButtonType.system)
        newButton.frame = CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height)
        newButton.backgroundColor = self.tintColor
        newButton.tintColor = self.tintColor
        newButton.addTarget(self, action: #selector(Palette.pressed(_:)), for: .touchUpInside)
        newButton.tag = self.subviews.count
        newButton.palette = self
        if self.subviews.count > 0 {
            let firstButton = self.subviews[0] as! PaletteButton
            self.insertSubview(newButton, belowSubview: firstButton)
        } else {
            self.addSubview(newButton)
        }
        
        updateFrames()
        return newButton
    }
    
    func removeButtonAtIndex(_ index: Int) -> Bool {
        if (self.subviews.count > 1 && index < self.subviews.count) {
            if let button = getButtonAtIndex(index) {
                button.removeFromSuperview()
                updateFrames()
                return true
            }
        }
        
        return false
    }
    
    func updateFrames() {
        let widthBefore = self.frame.size.width
        let newWidth = self.buttonSize.width * CGFloat(self.subviews.count)
        let xOffset = widthBefore - newWidth
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.frame.origin.x = self.frame.origin.x + xOffset
            self.frame.size.width = newWidth
            var index = 0
            for view in self.subviews {
                if let button = view as? PaletteButton {
                    button.frame.origin.x = self.buttonSize.width * CGFloat(index)
                    index += 1
                }
            }
            }, completion: { finished in
                self.delegate?.paletteFrameUpdated(self.frame)
        })
        
    }
    
    func buttonIsCurrentLayer(_ button: PaletteButton) {
        if (button != selectedButton) {
            selectedButton?.isCurrentLayer = false
            selectedButton = button
            for view in self.subviews {
                view.setNeedsDisplay()
            }
        }
    }
    
    func pressed(_ button: PaletteButton!) {
        button.isCurrentLayer = true
        self.delegate?.paletteColorPressed(button, index: button.tag)
    }
}
