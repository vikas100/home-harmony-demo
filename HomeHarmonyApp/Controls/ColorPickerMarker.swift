//
//  ColorPickerMarker.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/11/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

@IBDesignable
class ColorPickerMarker: UIView {
    
    @IBInspectable var borderSize:CGFloat = 3.0
    
    private var color: UIColor!;
    
    override var backgroundColor: UIColor?  {
        didSet {
            if (backgroundColor != UIColor.clearColor()) {
                color = backgroundColor
                self.backgroundColor = UIColor.clearColor();
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        self.opaque = false
        
        CGContextClearRect(context, rect)
        
        if let color = color {
            
            //STROKE LINES
//            var hue:CGFloat = 0
//            var intensity:CGFloat = 0
//            var saturation:CGFloat = 0
//            color.getHue(&hue, saturation: &saturation, brightness: &intensity, alpha: nil)
            
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillEllipseInRect(context, rect)
            
            CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor)
            CGContextSetLineWidth(context, borderSize);
            
            CGContextStrokeEllipseInRect(context, CGRect(x: borderSize/2.0, y: borderSize/2.0, width: rect.width - borderSize, height: rect.height - borderSize))
            
        }
    }
}