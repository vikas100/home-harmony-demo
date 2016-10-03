//
//  PaletteButton.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/3/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

@IBDesignable
class PaletteButton: UIButton {
    
    weak internal var palette: Palette?
    let upImage = UIImage(named: "PaletteArrowUp")
    let downImage = UIImage(named: "PaletteArrowDown")
    let innerShadowLayer = CAShapeLayer()
    
    var storedColor:UIColor = CAMBRIAN_COLOR
    
    fileprivate func initialize() {
        self.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if let bgColor = backgroundColor {
                var alpha:CGFloat = 0
                bgColor.getHue(nil, saturation: nil, brightness: nil, alpha: &alpha)
                
                if (alpha == 1.0) {
                    storedColor = bgColor
                    if (isGhost) {
                        self.isOpaque = false
                        self.backgroundColor = UIColor.clear
                    }
                }
            }
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isGhost:Bool = false {
        didSet {
            if (isGhost) {
                self.isOpaque = false
                self.backgroundColor = UIColor.clear
            } else {
                self.backgroundColor = storedColor
            }
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isEditing:Bool = false {
        didSet {
            setNeedsDisplay();
        }
    }
    
    var isCurrentLayer:Bool = false {
        didSet {
            if (isCurrentLayer) {
                palette?.buttonIsCurrentLayer(self)
            }
            setNeedsDisplay();
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        self.isOpaque = false
        
        drawShadows(self.bounds)
        
        if (self.isGhost) {
            self.setImage(nil, for: UIControlState())
            self.setTitle("New", for: UIControlState())
            self.setTitleColor(UIColor.black, for: UIControlState())
            
            super.draw(rect)
            
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(self.storedColor.cgColor)
            context?.setLineWidth(3.0);
            let dashPattern:[CGFloat] = [6.0, 6.0]

            context?.setLineDash(phase: 0.0, lengths: dashPattern)
            
            let strokeRect = CGRect(x:4,y:4,width:rect.width-8,height:rect.height-8)
            context?.stroke(strokeRect)
            
            innerShadowLayer.shadowOpacity = 0.0
        } else {
            self.setTitle(nil, for: UIControlState())
            self.tintColor = isLightColor(self.storedColor) ? UIColor.black : UIColor.white
            
            if (self.isCurrentLayer) {
                if (self.isEditing) {
                    self.setImage(downImage, for: UIControlState())
                } else {
                    self.setImage(upImage, for: UIControlState())
                }
                innerShadowLayer.shadowOpacity = 0.0
            } else {
                self.setImage(nil, for: UIControlState())
                innerShadowLayer.shadowOpacity = 0.5
            }
            super.draw(rect)
            
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(self.storedColor.cgColor)
            context?.fill(rect)
        }
    }
    
    func drawShadows(_ rect: CGRect) {

        innerShadowLayer.frame = rect
        
        innerShadowLayer.shadowColor = UIColor.black.cgColor
        innerShadowLayer.shadowOffset = CGSize(width: 0, height: 3.0)
        
        // Standard shadow stuff
        innerShadowLayer.shadowOpacity = 0.5
        innerShadowLayer.shadowRadius = 3
        
        // Causes the inner region in this example to NOT be filled.
        innerShadowLayer.fillRule = kCAFillRuleEvenOdd
        
        // Create the larger rectangle path.
        let path = CGMutablePath();
        
        path.addRect(bounds.insetBy(dx: -42, dy: -42))
        
        // Add the inner path so it's subtracted from the outer path.
        // someInnerPath could be a simple bounds rect, or maybe
        // a rounded one for some extra fanciness.
        
        let higherLayer = self.palette?.getButtonAtIndex(self.tag + 1)
        
        var innerRect:CGRect
        let hasRightShadow = self.tag == 0 || self.palette?.selectedButton?.tag == self.tag - 1
        let hasLeftShadow = (self.palette?.selectedButton?.tag == self.tag + 1) || (higherLayer == nil || higherLayer!.isGhost)
        
        //print("button \(self.tag) hasRightShadow: \(hasRightShadow), hasLeftShadow: \(hasLeftShadow)");
        
        if (hasLeftShadow && hasRightShadow) {
            innerRect = innerShadowLayer.bounds
        } else if (hasLeftShadow) {
            innerRect = CGRect(x:0, y: 0, width: innerShadowLayer.bounds.size.width + 10, height: innerShadowLayer.bounds.size.height)
        } else if (hasRightShadow) {
            innerRect = CGRect(x:-10,y:0, width: innerShadowLayer.bounds.size.width + 10, height: innerShadowLayer.bounds.size.height)
        } else {
            innerRect = CGRect(x:-10,y:0, width: innerShadowLayer.bounds.size.width + 20, height: innerShadowLayer.bounds.size.height)
        }

        let someInnerPath = UIBezierPath(rect: innerRect).cgPath
        
        path.addPath(someInnerPath)
        path.closeSubpath();
        
        //let maskLayer = CALayer()
        //innerShadowLayer.mask = maskLayer
        innerShadowLayer.path = path
        self.layer.addSublayer(innerShadowLayer)
    }
}
