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
    
    private func initialize() {
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
                        self.opaque = false
                        self.backgroundColor = UIColor.clearColor()
                    }
                }
            }
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isGhost:Bool = false {
        didSet {
            if (isGhost) {
                self.opaque = false
                self.backgroundColor = UIColor.clearColor()
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
    
    override func drawRect(rect: CGRect) {
        
        self.opaque = false
        
        drawShadows(self.bounds)
        
        if (self.isGhost) {
            self.setImage(nil, forState: UIControlState.Normal)
            self.setTitle("New", forState: UIControlState.Normal)
            self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            
            super.drawRect(rect)
            
            let context = UIGraphicsGetCurrentContext()
            CGContextSetStrokeColorWithColor(context, self.storedColor.CGColor)
            CGContextSetLineWidth(context, 3.0);
            let dashPattern:[CGFloat] = [6.0, 6.0];
            CGContextSetLineDash(context, 0.0, dashPattern, 2);
            
            let strokeRect = CGRect(x:4,y:4,width:rect.width-8,height:rect.height-8)
            CGContextStrokeRect(context, strokeRect)
            
            innerShadowLayer.shadowOpacity = 0.0
        } else {
            self.setTitle(nil, forState: UIControlState.Normal)
            self.tintColor = isLightColor(self.storedColor) ? UIColor.blackColor() : UIColor.whiteColor()
            
            if (self.isCurrentLayer) {
                if (self.isEditing) {
                    self.setImage(downImage, forState: UIControlState.Normal)
                } else {
                    self.setImage(upImage, forState: UIControlState.Normal)
                }
                innerShadowLayer.shadowOpacity = 0.0
            } else {
                self.setImage(nil, forState: UIControlState.Normal)
                innerShadowLayer.shadowOpacity = 0.5
            }
            super.drawRect(rect)
            
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, self.storedColor.CGColor)
            CGContextFillRect(context, rect)
        }
    }
    
    func drawShadows(rect: CGRect) {

        innerShadowLayer.frame = rect
        
        innerShadowLayer.shadowColor = UIColor.blackColor().CGColor
        innerShadowLayer.shadowOffset = CGSize(width: 0, height: 3.0)
        
        // Standard shadow stuff
        innerShadowLayer.shadowOpacity = 0.5
        innerShadowLayer.shadowRadius = 3
        
        // Causes the inner region in this example to NOT be filled.
        innerShadowLayer.fillRule = kCAFillRuleEvenOdd
        
        // Create the larger rectangle path.
        let path = CGPathCreateMutable();
        CGPathAddRect(path, nil, CGRectInset(bounds, -42, -42));
        
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

        let someInnerPath = UIBezierPath(rect: innerRect).CGPath
        CGPathAddPath(path, nil, someInnerPath);
        CGPathCloseSubpath(path);
        
        //let maskLayer = CALayer()
        //innerShadowLayer.mask = maskLayer
        innerShadowLayer.path = path
        self.layer.addSublayer(innerShadowLayer)
    }
}